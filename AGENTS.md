# AGENTS.md: 動物輔助治療 × 思覺失調症負性症狀 LLM Wiki 系統規範

本文件為本知識庫的核心架構憲法（The Schema）。任何維護本知識庫的 AI Agent 皆必須嚴格遵守本文件所載之原則、目錄結構、操作 SOP 與格式規範。

---

## 1. 核心定位與願景 (Core Philosophy & Mission)

本知識庫基於 **Andrej Karpathy 的 LLM Wiki 模式** 建立，專門整理與演化**「動物輔助治療（Animal-Assisted Therapy, AAT / AAA）對思覺失調症（Schizophrenia）負性症狀之療效、機制與大眾轉譯」**。

### 核心原則：
1. **知識持續複利（Compounding Artifact）**：知識不是每次查詢時從原始文獻重新檢索，而是隨著每篇文獻的讀入，持續沉澱、交叉鏈結、標註矛盾與演化假說。
2. **原始文獻不可變（Source of Truth）**：`raw/` 目錄為唯一真實來源，唯讀且不可由 Agent 竄改。
3. **走出學術象牙塔（Public Translation & De-stigmatization）**：本知識庫面向**多層次讀者**。核心分析維持高度醫學與統計嚴謹性，但**所有文獻摘要與核心概念頁面，皆強制包含平易近人的「臨床實務與日常生活/大眾轉譯」解讀**，旨在促進社會大眾對負性症狀的理解與去污名化。
4. **雙向鏈結與圖譜導向（Graph-Native）**：全面採用 Obsidian 雙向鏈結語法 `[[...]]`，使概念、文獻、量表與機轉形成緊密網絡。

---

## 2. 目錄結構與職責 (Directory Structure)

```text
├── raw/                               # 原始文獻庫（唯讀 Source of Truth，存放 PDF / Markdown 論文）
│   └── README.md
│
├── wiki/                              # Agent 維護的 Wiki 本體層
│   ├── index.md                       # 內容總目錄導覽（依類別索引所有頁面）
│   ├── log.md                         # 變更紀錄日誌（記錄每次 Ingest / Query / Lint）
│   │
│   ├── sources/                       # 單篇論文結構化萃取頁面（檔名：YYYY-firstauthor-keyword.md）
│   │
│   ├── concepts/                      # 四大核心實體頁面
│   │   ├── symptoms/                  # 負性症狀細項（如 avolition.md, blunted-affect.md, asociality.md）
│   │   ├── interventions/             # 動物介入類型（如 canine-aat.md, equine-aat.md, group-vs-individual.md）
│   │   ├── measures/                  # 評估量表（如 panss-negative.md, sans.md, bnss.md）
│   │   └── mechanisms/                # 生理心理機轉（如 oxytocin.md, attachment.md, hpa-axis.md）
│   │
│   ├── comparisons/                   # 跨研究比較矩陣（橫向對比表，如不同動物或不同劑量療效比較）
│   ├── syntheses/                     # 綜合綜述與大眾科普主題篇章（如特定症狀改善綜述、去污名化專文）
│   ├── methodology/                   # 研究限制與偏誤評估（RoB 分析、TAU 對照組設計限制）
│   └── hypotheses/                    # 未解問題與待驗證假說清單（如 open-questions.md）
│
└── AGENTS.md                          # 本規範文件
```

---

## 3. 命名與引註規範 (Conventions & Provenance)

1. **檔案命名**：
   - 文獻頁面（Sources）：`YYYY-firstauthor-keyword.md`（例如：`2023-villalta-gil-dog-aat.md`，全小寫、連字號）。
   - 概念頁面（Concepts）：以英文術語或標準縮寫命名（例如：`avolition.md`、`canine-aat.md`、`panss-negative.md`）。
2. **語言規範**：
   - 內文以**繁體中文**為主。
   - 核心精神醫學與心理專有名詞，首次出現時必須附帶**英漢對照**（例如：「動機缺乏 (Avolition)」、「催產素 (Oxytocin)」）。
3. **文獻引註顆粒度**：
   - 採用**文獻頁面級雙向鏈結**：在各概念頁、比較表與綜述中，統一使用 `[[YYYY-firstauthor-keyword]]`（例如 `[[2023-villalta-gil-dog-aat]]`）。
   - 點擊該鏈結可跳轉至對應 Source 頁面查閱詳細數據（樣本數 n、p 值、效應值 Cohen's d、量表分數、頁數與圖表）。

---

## 4. 矛盾與衝突處理機制 (Contradiction Handling Protocol)

當不同文獻的研究結果出現衝突（例如：A 研究指出犬類 AAT 顯著改善情感冷漠，B 研究卻顯示與常規治療無顯著差異）時：
1. **嚴禁忽視或私自抹平矛盾**。
2. 必須在相關的概念頁（Concepts）與綜述頁（Syntheses）的專屬章節 `## 爭議與分歧解析 (Contradictions & Divergent Findings)` 中並列記錄。
3. **強制從以下四個方法學維度剖析衝突成因**：
   - **介入劑量與時長**：總週數、每週頻率、單次時長是否足夠產生神經可塑性或依附關係？
   - **對照組性質**：對照組是純「常規治療 (Treatment as Usual, TAU)」，還是具備社交性質的「積極對照組 (Active Control，如休閒園藝、桌遊活動)」？
   - **樣本特徵與規模**：樣本數 n、統計檢定力 (Power)、住院個案 (Inpatients) vs 社區復健個案 (Outpatients)？
   - **量表敏感度**：採用的量表評估工具（如舊型 PANSS 負性次量表 vs 專門針對負性症狀新設計之 BNSS/CAINS）之敏感度差異。

---

## 5. 三大核心操作 SOP (Operations)

### SOP 1: 文獻匯入 (Ingest) — 兩階段人機互動模式

**階段一：研讀與提案（Proposal Phase）**
當使用者指示研讀 `raw/` 中的新文獻時，Agent 絕不能直接默默寫入 Wiki。Agent 必須先在對話中回報結構化提案：
1. **文獻基本資訊**：作者、年份、研究設計（RCT/準實驗/個案研究）、樣本數 n。
2. **核心研究發現**：對哪些具體負性症狀有統計顯著改善？關鍵數據為何？
3. **方法學限制與偏誤評估**：對照組設計、盲法限制、脫落率。
4. **與既有 Wiki 的共識與矛盾比對**：支持了哪篇文獻？與哪篇文獻衝突？
5. **🌟 日常生活與大眾轉譯點**：此發現對個案生活功能、家庭互動有何白話意義？
6. **擬新增與異動頁面清單**：列出預計建立的 Source 頁與需要連帶更新的 Concepts、Comparisons 頁面。

**階段二：確認與寫入（Commit Phase）**
待使用者回覆確認、調整重點或給予補充指示後，Agent 方可執行：
1. 建立 `wiki/sources/YYYY-author-keyword.md`。
2. 更新相關的 `wiki/concepts/...` 頁面（加入新證據與更新矛盾解析專區）。
3. 視需要更新 `wiki/comparisons/` 與 `wiki/hypotheses/`。
4. 更新 `wiki/index.md` 中的分類目錄。
5. 於 `wiki/log.md` 追加一筆標準日誌（格式：`## [YYYY-MM-DD] ingest | 文獻標題`）。

---

### SOP 2: 查詢與綜合產出 (Query & Deliverables)

當使用者針對特定主題提問（例如：「犬類介入對動機缺乏的療效如何？」或「請幫我寫一篇給家屬看的動物輔助治療科普文」）時：
1. Agent 先讀取 `wiki/index.md` 定位相關頁面，跨頁面檢索並綜合提煉答案。
2. **多形式產出支援**：
   - **學術回顧草稿**：帶有嚴謹論點、研究比較與引用標籤之 Markdown 篇章。
   - **橫向比較矩陣**：結構化 Markdown 表格或對比清單。
   - **大眾科普與衛教專文**：生動、有溫度、以生活情境出發的去污名化解說文章。
   - **簡報投影片**：符合 Marp 格式的簡報 Markdown。
3. **知識回流（Filing Back）**：若產出的綜合分析、比較矩陣或科普文章具備持久價值，Agent 應主動建議使用者將其回寫存入 `wiki/syntheses/` 或 `wiki/comparisons/`。

---

### SOP 3: 知識庫健康檢查 (Lint)

當使用者下達 Lint 檢查指令時，Agent 必須系統性執行以下巡檢並產出診斷報告：
1. **拓撲結構檢查**：
   - 是否存在孤立頁面（Orphan Pages，即無任何其他頁面反向鏈結者）？
   - 是否存在死鏈結（Broken Links，鏈結指向不存在的頁面）？
   - `wiki/index.md` 是否遺漏收錄任何新建頁面？
2. **學術論證與矛盾檢查**：
   - 是否有新文獻已經挑戰或推翻舊論點，但舊頁面尚未更新標註？
   - 是否存在無 `[[文獻代號]]` 支持的空泛宣稱？
3. **概念與文獻缺口檢查**：
   - 內文中反覆出現但尚未獨立建頁的核心概念（如某個新興量表或生化指標）。
   - 盤點哪些負性症狀（如言語貧乏 Alogia）實證文獻最薄弱，提出後續檢索建議。
4. **🌟 大眾轉譯完整度檢查（強制項）**：
   - 逐一檢查所有 `sources/` 與 `concepts/` 頁面，**確認是否皆包含合格的「臨床實務與日常生活/大眾轉譯」章節**；若缺少，必須列入待補齊清單。

---

## 6. 標準頁面模板 (Page Templates)

### 範本 A：單篇文獻萃取頁 (`wiki/sources/YYYY-author-keyword.md`)

```markdown
---
title: "論文標題"
authors: "第一作者 et al."
year: 2023
study_type: "RCT / 準實驗 / 系統性回顧"
sample_size: 45
intervention_type: "Canine-AAT / Equine-AAT / AAA"
target_symptoms: ["avolition", "asociality", "blunted-affect"]
outcome_measures: ["PANSS-Negative", "SANS"]
tags: [source, canine, rct, inpatient]
date_ingested: YYYY-MM-DD
---

# 論文標題 (中文摘要名)

- **原始文獻出處**：[[raw/檔名.pdf]] 或 DOI 網址
- **研究設計**：例如 單盲隨機對照試驗 (RCT, n=45, 介入組 23 人 vs 常規對照組 22 人)
- **介入參數**：治療犬、每週 1 次、每次 50 分鐘、共 12 週、職能治療師與合格動輔師共同帶領

## 1. 核心實證發現 (Key Findings)
- 對於 [[avolition]]（動機缺乏）：介入組在 [[panss-negative]] 評分於第 12 週顯著降低 (p = 0.02, d = 0.65)。
- 對於 [[asociality]]（社交退縮）：觀察到自發性社交互動頻率增加。

## 2. 方法學限制與偏誤評估 (Methodology & Limitations)
- 樣本數較小，未追蹤結束後 6 個月之長期維持成效。
- 對照組為常規醫療 (TAU)，未設置非動物之積極社交對照組。

## 3. 與既有文獻之關聯 (Cross-References & Debates)
- 支持了 [[2019-previous-study]] 關於犬類提升社交意願的假說。
- 與 [[2021-other-study]] 在情感冷漠改善上之結論不一致（可能因介入劑量不同）。

## 4. 🌟 臨床實務與日常生活/大眾生活功能意涵 (Public & Daily Life Meaning)
> **大眾解讀視角**：
> 本研究說明了「為什麼不是叫個案自己出門走走就好」。透過狗狗無條件接納的特質，個案在沒有社交評判壓力的環境下，重新找回「想去摸摸狗、想帶牠散步」的主動渴望，這種內在動機是藥物難以單獨達成的。
```

---

### 範本 B：概念/實體頁 (`wiki/concepts/symptoms/avolition.md`)

```markdown
---
title: 動機缺乏 (Avolition)
category: symptom
tags: [concept, symptom, negative-symptom]
last_updated: YYYY-MM-DD
---

# 動機缺乏 (Avolition)

> [!SUMMARY] 一句話精華
> 思覺失調症最難透過傳統抗精神病藥物改善的核心負性症狀之一，表現在自主啟動與維持目標導向活動的能力顯著低下。

## 1. 概念與臨床評估
- 評估工具涵蓋 [[panss-negative]]、[[sans]]、[[bnss]]。
- 與情感平淡 ([[blunted-affect]])、社交退縮 ([[asociality]]) 具高度共病性，但神經機制不盡相同。

## 2. 動物輔助治療之實證總結
- 犬類介入實證支持：[[2023-villalta-gil-dog-aat]] 指出結構化互動能活化行為啟動。
- 馬類介入實證支持：...

## 3. 爭議與分歧解析 (Contradictions & Divergent Findings)
| 支持顯著療效之研究 | 顯示無顯著差異之研究 | 方法學分歧拆解（劑量/對照組/量表） |
| :--- | :--- | :--- |
| [[2023-villalta-gil-dog-aat]] | [[2020-smith-negative-trial]] | 介入時長（12週 vs 4週）；且後者採用積極對照組（桌遊社交），顯示動物特異效應需更長累積 |

## 4. 作用機轉與假說
- 連結至神經生化假說 [[oxytocin]] 與多巴胺獎勵預測誤差修復。
- 連結至依附與安全感假說 [[attachment]]。

## 5. 🌟 臨床實務與日常生活/大眾生活功能意涵 (Public & Daily Life Meaning)
> **大眾與家屬視角**：
> 當個案整天躺在床上、連換衣服洗澡都顯得困難時，常被誤解為「不長進、懶惰」。實際上這是大腦神經傳導物質功能受損導致的「動機引擎熄火」。動物輔助治療就像是一個外接的啟動馬達，藉由人與動物間最原始的情感連結，讓個案為了照顧、撫摸小動物而自發站起來，重燃對生活的自主掌控感。
```
