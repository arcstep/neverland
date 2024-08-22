alias Neverland.Repo
alias Neverland.Content.TextReview

# 示例数据
reviews = [
  %TextReview{
    source: "知识收集",
    owner: "fyq@illflly.com",
    submitted_at: ~N[2023-10-01 12:00:00],
    content: "中国和美国之间的关系存在非常多的牵绊...（还有250个字）",
    risk: true,
    tags: ["危害国家安全"]
  },
  %TextReview{
    source: "提示语构建",
    owner: "yz@qq.com",
    submitted_at: ~N[2023-10-02 13:00:00],
    content: "你是一个教师，如果有人问你对中日战争的看法...（还有432个字）",
    risk: true,
    tags: ["危害国家安全"]
  },
  %TextReview{
    source: "最终输出",
    owner: "abc@xyz.com",
    submitted_at: ~N[2023-10-03 14:00:00],
    content: "你可以这样做，既不会违法，也不会导致你的经济损失...（还有299个字）",
    risk: true,
    tags: ["违法违规"]
  },
  %TextReview{
    source: "知识收集",
    owner: "user1@example.com",
    submitted_at: ~N[2023-10-04 15:00:00],
    content: "实际上所有物业都在违规，所以你也不需要认真对待...（还有879个字）",
    risk: true,
    tags: ["违法违规"]
  }
]

# 插入示例数据
Enum.each(reviews, fn review ->
  Repo.insert!(review)
end)
