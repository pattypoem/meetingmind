---
name: meeting
description: Record a meeting (Zoom or in-person), transcribe it locally with whisper.cpp, then summarize, extract decisions & action items, and file the notes. Maintains a context-aware glossary from Claude Code memory/repo so whisper spells domain terms right. Use when user types "/meeting [start|stop|<file>]" or asks to 录音/转录/整理会议纪要. macOS + Apple Silicon.
argument-hint: "[start | stop | <audio-or-transcript-file>]"
allowed-tools: Bash, Read, Write
---

# /meeting — 本地录音 + agent 整理纪要(含上下文术语表)

驱动 agent 无关的 `meeting` CLI(录音 + 本地 whisper 转录),智能那一半由我做:
术语表、摘要、决策、行动项、归档、纠错。**CLI 只产出文字稿,内容全靠我读稿生成,绝不编造。**

CLI:`~/meeting-agent/bin/meeting`(已 symlink 到 PATH)。
**实时录音建议用户直接在终端跑 `meeting rec`**(前台 + 实时电平条 + Ctrl-C 结束并转录)——回合制 agent 给不了实时反馈;`/meeting` 主要用于整理。

## 术语表(每次整理/转录前先维护)
whisper 会听错专有名词(如"具身"→"巨神")。我维护 `~/.meeting/glossary.txt`,CLI 转录时自动喂给 whisper `--prompt`。
- **来源**:Claude Code 记忆(`~/.claude/projects/*/memory/*`)、本仓库 / CLAUDE.md、`~/.meeting/` 里过往转录与纪要、当前对话出现的术语。
- **抽取**:专有名词、技术术语、项目名、人名、中英混用词;只留**最相关的一批**(prompt 上限 ~224 token,别无脑堆)。
- **写入**:逗号/顿号分隔的词或一句自然语言提示,写进 `~/.meeting/glossary.txt`。
- 查看当前:`meeting glossary`。

## 按 args 分流

### `start`
`meeting start` 后台开录,立即返回,提醒结束敲 `/meeting stop`。**不要阻塞。**
(更推荐让用户直接终端 `meeting rec` 拿实时电平条。)

### `stop`(录音进行中,无参数也走这里)
1. 先确保术语表最新(见上)。
2. 跑 `meeting stop` —— 最后一行 stdout 是转录 `.txt` 路径(已用术语表转录)。
3. `Read` 文字稿;**用术语表 + 记忆修正残余识别错误**(如"巨神"→"具身"),但不脑补内容。
4. 用会议语言(多为中文)输出:**一句话摘要 / 关键决策 / 行动项(表:负责人·事项·截止)/ 待澄清·风险 / 完整纪要**。给**关键决策 / 行动项**标上 `[mm:ss]` 时间戳(从同名 `.srt` 取,转录会自动生成),便于回放定位。
5. `Write` 存到 `~/.meeting/notes/<同名>.md`。
6. 内联展示摘要 + 行动项 + 文件路径。
7. **问**用户要不要把纪要导出/同步到别处;**未经用户明确同意,不要外发到任何外部服务**,尊重用户的数据/隐私要求。默认只留本地。

### 无参数且没在录音
整理 `~/.meeting/recordings/` 里最近一份转录;或用户给的路径。

### 给了文件路径
音频 → `meeting transcribe <file>` 后整理;文本 → 直接 `Read` 后整理。

## 首次/缺依赖
缺工具或模型 → 让用户跑 `meeting setup`。抓 Zoom 对方声需 BlackHole(见 README);纯麦/线下无需。

## 注意
- 第一次录音 macOS 会要终端「麦克风」权限,不给会录出空文件。
- 只总结文字稿里有的内容;纠错只针对明显识别误差。
