#!/bin/bash
# 生成 4 位随机字符串（大小写字母 + 数字）
SLUG=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 4)

# 使用 hexo new 创建文章
hexo new "$SLUG"

# 自动在 Front-matter 中写入 slug（可选，因为文件名就是 slug，但显式写更保险）
FILE="source/_posts/${SLUG}.md"
sed -i "2i slug: $SLUG" "$FILE"

echo "✅ 已创建文章：$SLUG"
echo "📄 文件路径：$FILE"