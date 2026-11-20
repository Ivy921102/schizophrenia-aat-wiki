# 知識庫變更日誌 (Knowledge Base Log)

> 本日誌為唯增（Append-Only）的時間軸紀錄，記錄所有重要操作（`ingest`、`query`、`lint`、`init`）。
> 遵循 Karpathy 規範，每筆開頭使用標準標籤格式以利檢索。

---

## [2026-11-17] refactor | 知識庫標題與呈現優化
- **動作**：
  - 更新知識庫主標題為「動物輔助治療對思覺失調症及相關譜系障礙負性症狀的療效」。
  - 聚焦首頁介紹於負性症狀臨床困境與動物輔助治療之核心實證，精簡結構清單。
  - 全面優化統計數據與符號呈現（全面轉換為乾淨純文字與 Unicode，修復 GitHub 渲染問題）。
- **影響範圍**：`README.md`、`wiki/index.md`、`wiki/sources/*.md`、`wiki/concepts/**/*.md`、`wiki/comparisons/*.md`、`wiki/methodology/*.md`、`wiki/syntheses/*.md`。

## [2026-11-17] init | 建立知識庫架構與 AGENTS.md 系統規範
- **動作**：初始化 Wiki 檔案結構與核心系統規範。
- **配置**：
  - 確立以「動物輔助治療對思覺失調症負性症狀」為核心主題。
  - 確立雙層讀者定位：高規格學術分析 ＋ 平實大眾生活轉譯（去污名化）。
  - 建立四大概念分類（症狀、介入、量表、機轉）與四大專門頁面目錄（comparisons, syntheses, methodology, hypotheses）。
  - 設定兩階段互動式 Ingest SOP、四維度矛盾拆解協議與全方位 Lint 巡檢標準。
- **影響範圍**：新增 `AGENTS.md`、`raw/README.md`、`wiki/index.md`、`wiki/log.md`、`wiki/hypotheses/open-questions.md`。


## [2026-11-17] ingest | 2026-peraile-huerta-aat-psychosis-meta
- **文獻**：Peraile-Huerta et al. (2026) *Complementary Therapies in Medicine*
- **動作**：完成第一篇文獻（2026 統合分析）兩階段 Ingest 之寫入階段（Commit Phase）。
- **影響範圍**：
  - 新建文獻頁：[[2026-peraile-huerta-aat-psychosis-meta]]
  - 新建/更新概念頁：[[avolition]]（動機缺乏）、[[anhedonia]]（無快感症）、[[canine-aat]]（犬類輔助治療）、[[panss-negative]]（PANSS 負性次量表）、[[oxytocin]]（催產素假說）
  - 新建比較表：[[negative-symptoms-meta-comparison]]（6 項 RCT 負性症狀效應值對照）
  - 更新索引目錄：[[index|wiki/index.md]]
- **核心實證定錨**：確立了 AAT 改善思覺失調症負性症狀具備中等統計顯著效應值（SMD = -0.51, p < 0.05），打破過去認為實證不確定的保守觀點，並全數落實大眾生活轉譯章節。


## [2026-11-17] ingest | 2021-chen-dog-aat-taiwan-rct
- **文獻**：Chen et al. (2021) *Frontiers in Psychiatry*
- **動作**：完成第二篇文獻（台灣長庚／台大團隊犬類 RCT）兩階段 Ingest 之寫入階段（Commit Phase）。
- **格式規範執行**：依使用者指示，第一作者姓名嚴格使用英文格式（`Tzu-Ting Chen et al.`）。
- **影響範圍**：
  - 新建文獻頁：[[2021-chen-dog-aat-taiwan-rct]]
  - 新建概念頁：[[asociality]]（社交退縮）、[[blunted-affect]]（情感平淡）、[[social-scaffolding]]（社交鷹架理論）
  - 新建比較表：[[canine-vs-equine]]（犬類 Chen 2021 vs 馬匹 Öztürk 2025 在負性症狀與孤獨感上的機制分歧剖析）
  - 更新索引目錄：[[index|wiki/index.md]]
- **核心實證定錨**：確立了 12 週犬類介入對中老年慢性思覺失調個案負性症狀的大效應改善（SRD = 0.50, p < 0.001）、0% 脫落率之高度可行性，以及跨專業（職能治療＋動輔師）四階社交鷹架操作模型。


## [2026-11-17] ingest | 2025-ozturk-equine-aat-rct
- **文獻**：Öztürk et al. (2025) *Journal of Psychosocial Nursing and Mental Health Services*
- **動作**：完成土耳其馬術 RCT 文獻萃取與概念擴充。
- **影響範圍**：
  - 新建文獻頁：[[2025-ozturk-equine-aat-rct]]
  - 新建概念頁：[[equine-aat]]（馬術與馬匹輔助治療）
  - 核心實證定錨：揭示馬匹介入對孤獨感消融（d=0.99）與生活品質提升（d=1.93）具備爆發性效果，但對負性量表無顯著差異之機轉解析。

## [2026-11-17] ingest | 2016-calvo-dog-aat-rehab-rct
- **文獻**：Calvo et al. (2016) *Frontiers in Psychology*
- **動作**：完成西班牙長週期（6 個月）犬類 RCT 文獻萃取。
- **影響範圍**：
  - 新建文獻頁：[[2016-calvo-dog-aat-rehab-rct]]
  - 新建概念頁：[[cortisol-hpa]]（皮質醇與壓力調節）
  - 核心實證定錨：確認了犬隻互動 1 小時後個案唾液皮質醇顯著下降之客觀生化數據，以及高達 92.9% 的復健出席率。

## [2026-11-17] ingest | 2023-tyssedal-dog-assisted-review
- **文獻**：Tyssedal et al. (2023) *Frontiers in Psychiatry*
- **動作**：完成挪威犬類介入系統性回顧萃取。
- **影響範圍**：
  - 新建文獻頁：[[2023-tyssedal-dog-assisted-review]]
  - 新建方法學頁：[[active-control-challenges]]（積極對照組難題）、[[blind-assessment-limitations]]（雙盲限制與因應）
  - 核心實證定錨：落實 GRADE 證據分級，剖析對照組設置對療效大小之影響。

## [2026-11-17] ingest | 2019-hawkins-aat-schizophrenia-review
- **文獻**：Hawkins et al. (2019) *Journal of Psychiatric Research*
- **動作**：完成愛丁堡大學早期系統性回顧萃取。
- **影響範圍**：
  - 新建文獻頁：[[2019-hawkins-aat-schizophrenia-review]]
  - 核心實證定錨：建立早期實證基線，確立動物福祉（One Welfare / IAHAIO）之倫理規範。

## [2026-11-17] synthesis | from-isolation-to-connection
- **動作**：生成大眾科普與去污名化旗艦專文。
- **產出**：[[from-isolation-to-connection]]（《從封閉孤立到溫柔破冰：動物如何走入思覺失調個案的日常》），全方位轉譯負性症狀病理、犬馬媒介抉擇與家庭照護指引。

## [2026-11-21] docs | GitHub 雙平台入口導航與簡報連結整合
- **動作**：
  - 於專案首頁 `README.md` 頂端整合「雙平台獨立並存入口導航（Live Web Access）」。
  - 保留 `index.html` 作為純淨且獨立運作的 LLM Wiki 知識庫本體介面，不被簡報覆蓋或干擾。
  - 明確提供「LLM Wiki 知識庫線上首頁」與「15 頁互動簡報 (Slides)」兩組獨立網址與徽章連結。
  - 同步維護 `graph.html`（State Graph 四階段生成長圖）獨立瀏覽頁面。
- **影響範圍**：`README.md`、`wiki/log.md`。
