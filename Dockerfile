FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    python3.9 \
    python3-distutils \
    python3-pip \
    ffmpeg \
    git \
    aria2 \
    unzip

RUN pip install --upgrade pip

WORKDIR /app/openvoice

#V2
RUN pip install git+https://github.com/myshell-ai/MeloTTS.git
RUN python3 -m unidic download

RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://myshell-public-repo-host.s3.amazonaws.com/openvoice/checkpoints_v2_0417.zip -d /app/openvoice -o checkpoints_v2_0417.zip
RUN unzip /app/openvoice/checkpoints_v2_0417.zip
RUN mkdir /app/openvoice/openvoice && mv /app/openvoice/checkpoints_v2 /app/openvoice/openvoice/checkpoints_v2

WORKDIR /app/openvoice
COPY ./requirements.txt ./requirements.txt
COPY ./setup.py ./setup.py
COPY ./README.md ./README.md
RUN pip install -e .

EXPOSE 7860

COPY ./openvoice /app/openvoice/openvoice
COPY ./resources /app/openvoice/openvoice/resources

RUN sed -i "s/demo.launch(debug=True, show_api=True, share=args.share)/demo.launch(server_name='0.0.0.0', debug=True, show_api=True, share=args.share)/" /app/openvoice/openvoice/openvoice_app.py

WORKDIR /app/openvoice/openvoice
RUN ln -s ../resources resources

CMD ["python3", "-m", "openvoice_app" ,"--share"]