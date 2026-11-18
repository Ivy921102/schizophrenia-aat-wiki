# 簡報生成 State Graph 系統架構 (`graph/`)

本目錄實作基於 **LLM Wiki (`wiki/`)** 之**四階段狀態圖（State Graph）簡報生成工作流**，採用 **Shift-Left（品質左移）** 策略，在大綱與逐頁稿階段即透過「程式檢核 ＋ AI 審查 ＋ 人類確認（HITL）」層層把關，再進入互動網頁渲染。

---

## 1. 四階段 State Graph 完整長圖

![動物輔助治療 × 思覺失調症簡報生成 State Graph](slide_generation_graph.png)

*(原始向量檔：[slide_generation_graph.svg](slide_generation_graph.svg)｜產生腳本：[scripts/render_graph_png.ps1](scripts/render_graph_png.ps1))*

<details>
<summary>展開 Mermaid 原始碼</summary>

```mermaid
flowchart TD
    subgraph S1["第一階段：知識庫萃取與規格確立"]
        direction TB
        N0["Node 0: 需求規格化\n輸出 00_requirements.json"]
        N1["Node 1: Wiki 原始知識源\nwiki/*.md (6篇文獻+症狀+機轉+科普)"]
        N2["Node 2: Wiki 知識萃取\n輸出 01_wiki_knowledge.json"]
        G1{"Gate 1: Wiki 程式檢驗\nJSON合法？6篇文獻與3機轉齊全？\n輸出 01_check_report.json"}

        N0 --> N2
        N1 --> N2
        N2 --> G1
        G1 --"未通過：退回重抽"--> N2
    end

    subgraph S2["第二階段：大綱規劃與人類確認 (Shift-Left 核心)"]
        direction TB
        N3["Node 3: 14頁大綱與3互動頁規劃\n輸入 00+01 -> 輸出 02_outline.md"]
        G2{"Gate 2: 大綱合規檢驗 (程式+AI)\n1. 機制在文獻前 2. 6篇全列\n3. 零統計符號與無分歧 4. 3頁互動\n輸出 02_outline_review.json"}
        G3{"Gate 3: 人類介入關卡 1 (HITL)\n由使用者審閱並確認大綱\n(強制暫停)"}

        N3 --> G2
        G2 --"退回修改"--> N3
        G2 --"通過"--> G3
        G3 --"依修改指示"--> N3
    end

    subgraph S3["第三階段：逐頁內容編寫與雙重品管"]
        direction TB
        N4["Node 4: 逐頁詳細文案與互動題編寫\n輸入 02+01 -> 輸出 03_slides_content.json\n與 03_slides_draft.md"]
        G4{"Gate 4: 逐頁雙重品管 (程式+AI)\n1. Regex禁統計符號與異常國旗\n2. 6篇文獻與字數預算合規\n3. 大眾轉譯溫柔度與零幻覺\n輸出 04_audit_report.json"}
        G5{"Gate 5: 人類介入關卡 2 (HITL)\n由使用者審閱逐頁文字稿\n(強制暫停)"}

        N4 --> G4
        G4 --"文案或規則未過"--> N4
        G4 --"品管通過"--> G5
        G5 --"調整文案"--> N4
    end

    subgraph S4["第四階段：互動網頁封裝與最終驗收"]
        direction TB
        N5["Node 5: 互動式網頁簡報 HTML 編譯\n輸入 03 + assets/*.svg -> 輸出 slides.html"]
        G6{"Gate 6: 程式與瀏覽器互動驗收\n標楷體/SVG路徑/3頁互動/鍵盤翻頁\n輸出 05_build_check.json"}
        N6["Node 6: 最終交付與同步 GitHub\n更新 index.html 入口並推送"]

        N5 --> G6
        G6 --"樣式破版或互動異常"--> N5
        G6 --"驗收通過"--> N6
    end

    G1 --"通過"--> N3
    G3 --"確認大綱 OK"--> N4
    G4 --"缺少原始素材：退回重抽"--> N2
    G5 --"核准逐頁稿 OK"--> N5

    style G1 fill:#334155,stroke:#64748b,color:#f8fafc
    style G2 fill:#a7f3d0,stroke:#059669,color:#064e3b
    style G3 fill:#fbbf24,stroke:#d97706,color:#451a03
    style G4 fill:#fda4af,stroke:#e11d48,color:#4c0519
    style G5 fill:#fbbf24,stroke:#d97706,color:#451a03
    style G6 fill:#334155,stroke:#64748b,color:#f8fafc
```

</details>

> **防死迴圈保護（Escalation）**：任一自動化關卡（Gate 1 / Gate 2 / Gate 4 / Gate 6）連續退回超過 **3 次（`max_retries = 3`）**，流程即自動暫停並升級交由人工裁決。

---

## 2. 狀態檔案與檢查對照表 (`graph/state/`)

| 階段 | 節點 / 關卡 | 輸入檔案 | 輸出檔案 | 檢查方式 | 失敗退回目標 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **第一階段** | Node 0 / 1 / 2 + Gate 1 | `wiki/**/*.md` | `00_requirements.json`<br>`01_wiki_knowledge.json`<br>`01_check_report.json` | 程式驗證 (`check_node1.ps1`) | 退回 Node 2 |
| **第二階段** | Node 3 + Gate 2 / Gate 3 | `00` + `01` | `02_outline.md`<br>`02_outline_review.json` | 程式＋AI (`check_node2.ps1`)<br>**人類介入關卡 1 (強制)** | 退回 Node 3 |
| **第三階段** | Node 4 + Gate 4 / Gate 5 | `02` + `01` | `03_slides_content.json`<br>`03_slides_draft.md`<br>`04_audit_report.json` | 程式 Regex ＋ AI 語意審查<br>**人類介入關卡 2 (強制)** | 文案錯退回 Node 4<br>缺素材退回 Node 2 |
| **第四階段** | Node 5 / 6 + Gate 6 | `03` + `assets/*.svg` | `slides.html`<br>`05_build_check.json` | 程式檢核 ＋ 瀏覽器人工驗收 | 僅退回 Node 5 |
