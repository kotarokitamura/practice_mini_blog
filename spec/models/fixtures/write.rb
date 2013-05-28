File.open('comments.yml','w'){|f|
  for num in 1..2000 do
    f.write <<EOS
comment#{num}:
  body: 'body#{num}'
  blog_id: '1'
  created_at: 2013-05-09 21:19:17 +0900

EOS
  end
}
