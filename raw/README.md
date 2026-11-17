# 原始文獻存放庫 (Raw Sources)

本資料夾為本 LLM Wiki 的唯一真實來源（Single Source of Truth），具有**唯讀（Immutable）**屬性。

## 使用指引
1. **存放格式**：請將欲研讀整理的論文 **PDF 全文** 或由 Zotero / Obsidian Web Clipper 匯出的 **Markdown 全文** 存放在此目錄下。
2. **命名建議**：建議採用 `YYYY-firstauthor-shorttitle.pdf`（例如：`2023-villalta-gil-dog-assisted-therapy.pdf`）。
3. **不可變更原則**：AI Agent 僅能讀取此資料夾內的檔案以萃取資訊，嚴禁修改、重寫或刪除此處的原始檔案。
4. **觸發匯入 (Ingest)**：存放新檔案後，在對話中告知 Agent（例如：「請研讀 raw/ 中的 2023-villalta-gil 文獻並進行 Ingest」），Agent 將啟動兩階段互動匯入流程。
