
#pip install --upgrade openai Flask python-dotenv
import os
from flask import Flask , request, render_template_string
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

client = OpenAI(
    api_key=os.environ.get("OPEN_API_KEY"),
    base_url=os.environ.get("LLM_ENDPOINT")
)


HTML_TEMPLATE= """ 
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AI Generated Poem</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f8fa;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            height: 100vh;
            margin: 0;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        form {
            background-color: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 400px;
        }
        textarea {
            width: 100%;
            height: 100px;
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 10px;
            font-size: 14px;
            resize: none;
        }
        button {
            margin-top: 10px;
            width: 100%;
            background-color: #10a37f;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0d8a6b;
        }
        .result {
            margin-top: 30px;
            background-color: #e9f7ef;
            border-left: 4px solid #10a37f;
            padding: 15px;
            border-radius: 8px;
            width: 400px;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <h1>AI Poem Generator</h1>
    <form method="POST">
        <textarea name="input" placeholder="Enter your prompt here..."></textarea>
        <button type="submit">Generate Network domain output</button>
    </form>

    {% if poem %}
    <div class="result">
        <h2>Your AI-Generated Poem</h2>
        <p>{{ poem }}</p>
    </div>
    {% endif %}
</body>
</html>
"""
@app.route("/", methods=["GET", "POST"])
def index():
    poem=None
    if request.method == "POST":
        try:
            input_message = request.form["input"]
            response= client.chat.completion.create(
                model=os.environ.get("MODEL"),
                messages=[
                    {"role": "system", 
                     "content": "you are an AI chatbot which specilaizes in Network domain"
                     },
                     {"role":"user",
                      "content": input_message
                      }
                ]
            )

            poem = response.choices[0].message.content
        except Exception as e:
            print("ERROR:", str(e))
            poem="An error occured when trying to fetch the poem"
    return render_template_string(HTML_TEMPLATE, poem=poem)

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    app.run(host="0.0.0.0", port=port)