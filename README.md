# 動物輔助治療 × 思覺失調症負性症狀：LLM Wiki 知識庫

> 本知識庫基於 **Andrej Karpathy 的 LLM Wiki 模式** 建立，專門整理「動物輔助治療（AAT）對思覺失調症負性症狀之療效、機制與大眾轉譯」之持久複利型文獻知識庫。
> 
> 本知識庫已將全部 6 篇原始文獻轉化為持續複利的網狀資產，不僅具備嚴謹的統計效應值與神經生化機轉，更完整落實了面向社會大眾的去污名化轉譯與臨床生活解讀。

---

## 🌐 知識庫核心架構與檔案清單

### 1. 導覽目錄與時間軸演化日誌
- 📑 [wiki/index.md](wiki/index.md)：全域雙向鏈結總索引（分類導覽所有概念與文獻）。
- 📝 [wiki/log.md](wiki/log.md)：完整記錄 6 篇文獻的 Ingest 與 Synthesis 時間軸事件。
- 📜 [AGENTS.md](AGENTS.md)：知識庫架構憲法與未來維護規範。

---

### 2. 單篇文獻萃取庫 (`wiki/sources/`)
*每篇文獻均包含：研究參數、統計數據、偏誤評估、跨文獻矛盾比對與大眾生活轉譯。*

- 📄 [2026-peraile-huerta-aat-psychosis-meta.md](wiki/sources/2026-peraile-huerta-aat-psychosis-meta.md)：
  - **地位**：最新 PRISMA 統合分析（12 篇研究、408 位個案）。
  - **實證標竿**：確立 AAT 對思覺失調負性症狀改善具備顯著中等效應值（$\text{SMD} = -0.51, p < 0.05$）。
- 📄 [2025-ozturk-equine-aat-rct.md](wiki/sources/2025-ozturk-equine-aat-rct.md)：
  - **地位**：土耳其 2025 年最新馬術 RCT（$n = 61$）。
  - **實證標竿**：揭示馬匹介入大幅消融孤獨感（$d = 0.99$）與提升生活品質（$d = 1.93$），但負性症狀無顯著差異之機轉解析。
- 📄 [2023-tyssedal-dog-assisted-review.md](wiki/sources/2023-tyssedal-dog-assisted-review.md)：
  - **地位**：挪威專注於犬類輔助介入（DAI）之系統性回顧（11 項研究）。
  - **實證標竿**：梳理各研究偏誤風險（RoB2 / GRADE），點出對照組設置差異對療效判讀的深層影響。
- 📄 [2021-chen-dog-aat-taiwan-rct.md](wiki/sources/2021-chen-dog-aat-taiwan-rct.md)：
  - **地位**：台灣高雄長庚與台大職能治療團隊 RCT（$n = 40$）。
  - **實證標竿**：12 週犬類介入負性症狀達成大效應值改善（$SRD = 0.50$）、達成 0% 脫落率，建立四階跨專業復健流程。
- 📄 [2019-hawkins-aat-schizophrenia-review.md](wiki/sources/2019-hawkins-aat-schizophrenia-review.md)：
  - **地位**：英國愛丁堡大學早期系統性回顧（7 項 RCT）。
  - **實證標竿**：建立歷史基線，率先呼籲重視試驗中的「動物福祉（One Welfare / IAHAIO）」規範。
- 📄 [2016-calvo-dog-aat-rehab-rct.md](wiki/sources/2016-calvo-dog-aat-rehab-rct.md)：
  - **地位**：西班牙 6 個月長週期 RCT（$n = 24$）。
  - **實證標竿**：證實接觸犬隻 1 小時後唾液皮質醇（壓力荷爾蒙）顯著下降，且復健出席率高達 92.9%（常規組僅 61.2%）。

---

### 3. 核心實體與概念網絡 (`wiki/concepts/`)

#### 負性症狀細項 (Symptoms)：
- 🧠 [avolition.md](wiki/concepts/symptoms/avolition.md)（動機缺乏）：解讀行為「引擎熄火」本質，動物作為外接啟動馬達。
- 👥 [asociality.md](wiki/concepts/symptoms/asociality.md)（社交退縮）：解析治療犬如何作為無威脅的第三者話題，搭起人際溝通橋樑。
- 🎭 [blunted-affect.md](wiki/concepts/symptoms/blunted-affect.md)（情感平淡）：探討內在感受未死、外在表達受阻，藉由觸摸重啟表情肌肉。
- 🌸 [anhedonia.md](wiki/concepts/symptoms/anhedonia.md)（無快感症）：納入 5 週快感感受力顯著回升實證，剖析多感官愉悅刺激。

#### 介入模式與媒介 (Interventions)：
- 🐕 [canine-aat.md](wiki/concepts/interventions/canine-aat.md)（犬類輔助治療）：負性症狀改善主力，涵蓋台灣四合一職能介入方案與標準團隊流程。
- 🐎 [equine-aat.md](wiki/concepts/interventions/equine-aat.md)（馬術與馬匹輔助治療）：全身律動、視野提升、尊嚴重建與孤獨感消融核心。

#### 評估量表 (Measures)：
- 📊 [panss-negative.md](wiki/concepts/measures/panss-negative.md)：拆解 7 項評估向度，將抽象的「下降 3 分」具體化為日常生活中的抬頭、微笑與開口。

#### 神經與心理機轉 (Mechanisms)：
- 🧬 [oxytocin.md](wiki/concepts/mechanisms/oxytocin.md)（催產素神經迴路）：人犬注視循環與哺乳動物生物級「安全信任感」。
- 🩸 [cortisol-hpa.md](wiki/concepts/mechanisms/cortisol-hpa.md)（皮質醇壓力調節）：解除中樞長年防空警報的客觀生化佐證。
- 🪜 [social-scaffolding.md](wiki/concepts/mechanisms/social-scaffolding.md)（社交鷹架理論）：四階漸進式職能復健架構（感官 $\rightarrow$ 指令 $\rightarrow$ 任務 $\rightarrow$ 社交泛化）。

---

### 4. 跨研究比較矩陣與方法學剖析
- ⚖️ [negative-symptoms-meta-comparison.md](wiki/comparisons/negative-symptoms-meta-comparison.md)：6 項 RCT 效應值、樣本數與對照組性質橫向對照表。
- ⚖️ [canine-vs-equine.md](wiki/comparisons/canine-vs-equine.md)：犬類 vs 馬匹在負性症狀與孤獨感上的機制分歧剖析。
- 🔬 [active-control-challenges.md](wiki/methodology/active-control-challenges.md)：積極對照組 vs 常規 TAU 設置對效應值之決定性影響。
- 🔬 [blind-assessment-limitations.md](wiki/methodology/blind-assessment-limitations.md)：雙盲限制與客觀生化標記因應策略。

---

### 5. 🌟 大眾科普與去污名化旗艦綜述
- 📖 [from-isolation-to-connection.md](wiki/syntheses/from-isolation-to-connection.md)：《從封閉孤立到溫柔破冰：動物如何走入思覺失調個案的日常》。
