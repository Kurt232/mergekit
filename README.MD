# env

```sh
uv venv --python 3.10 vv
source vv/bin/activate && uv pip install --upgrade pip -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
deactivate

git clone git@github.com:arcee-ai/mergekit.git
uv pip install -e mergekit -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
```

# note
1. not set chat_template is use the tokenizer's chat template