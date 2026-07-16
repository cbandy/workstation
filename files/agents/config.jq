def merge(a;b):
  if (a| type == "object") and (b| type == "object")
  then reduce (b| keys[]) as $k (a; .[$k] = merge(.[$k]; b[$k]))

  elif (a| type == "array") and (b| type == "array")
  then (a + b) | unique

  else b end
;

def transform:
  if (type == "string") and ((env.HOME // "") != "") then gsub("\\(~/"; "(\(env.HOME)/")
  elif (type == "array") then map(transform)
  elif (type == "object") then map_values(transform)
  else . end
;

map(transform) | reduce .[] as $v ({}; merge(.; $v))
