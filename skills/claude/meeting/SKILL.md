---
name: meeting
description: Record a meeting (Zoom or in-person), transcribe it locally with whisper.cpp, then summarize, extract decisions & action items, and file the notes. Use when user types "/meeting [start|stop|<file>]" or asks to 录音/转录/整理会议纪要. macOS + Apple Silicon; mic capture works out of the box, BlackHole needed for Zoom other-side audio.
argument-hint: "[start | stop | <audio-or-transcript-file>]"
allowed-tools: Bash, Read, Write
---

# /meeting — 本地录音 + agent 整理纪要

驱动 agent 无关的 `meeting` CLI(录音 + 本地 whisper 转录),智能那一半由我自己做:
摘要、决策、行动项、归档、按需路由。**CLI 只产出文字稿,内容全靠我读稿生成,绝不编造。**

CLI 路径:`~/meeting-agent/bin/meeting`(已 symlink 到 PATH;不在则用全路径调)。

## 按 args 分流

### `start`
```bash
meeting start
```
后台 ffmpeg 开录,立即返回。确认已开始录音,提醒用户结束时敲 `/meeting stop`。**不要阻塞等待。**

### `stop`(录音进行中时,无参数也走这里)
1. 跑 `meeting stop` —— 它最后一行 stdout 是转录 `.txt` 的路径。
2. `Read` 那个文字稿。
3. 用会议语言(多为中文)输出纪要,结构:
   - **一句话摘要**
   - **关键决策**(bullet)
   - **行动项** —— 表格:负责人 / 事项 / 截止
   - **待澄清 / 风险**
   - **完整纪要**(按主题分段)
4. `Write` 存到 `~/.meeting/notes/<同名>.md`。
5. 内联展示摘要 + 行动项,并告知文件路径。
6. **问**用户是否要路由出去(如 Notion MCP)—— 不要自动发送。

### 无参数且没在录音
整理 `~/.meeting/recordings/` 里最近一份转录;或用户给的路径。

### 给了文件路径
- 音频文件 → `meeting transcribe <file>` 转录后走上面的整理流程。
- 已是文本 → 直接 `Read` 后整理。

## 首次/缺依赖
若 CLI 报缺工具或模型,让用户跑 `meeting setup`(装 whisper.cpp + 下模型)。
要抓 Zoom 对方声音需装 BlackHole(见 README);纯麦克风/线下会议无需。

## 注意
- 第一次录音 macOS 会要终端的「麦克风」权限,不给会录出空文件。
- 只总结文字稿里有的内容,不脑补。
