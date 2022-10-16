
FROM condaforge/mambaforge as conda

ENV PIP_ROOT_USER_ACTION ignore

ADD environment.yml /

EXPOSE 8000

SHELL ["/bin/bash", "-c"]

RUN mamba install -y -n base -c conda-forge conda-lock && \
    mamba lock -p linux-64 -f /environment.yml && \
    mamba lock install -p /env /conda-lock.yml && \
    mamba clean -afy && \
    pip cache remove "*" 

RUN find -name '*.a' -delete && \
  rm -rf /env/conda-meta && \
  rm -rf /env/include && \
  find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \ 
  find /env/lib/python3.10/site-packages -name 'tests' -type d -exec rm -rf '{}' '+' && \
  find /env/lib/python3.10/site-packages -name '*.pyx' -delete 

FROM ubuntu:18.04

ADD jupyterhub_config.py /etc/jupyterhub/

COPY --from=conda /env /env

CMD PATH=$PATH:/env/bin /env/bin/jupyterhub --port 8000 --ip=0.0.0.0 -f /etc/jupyterhub/jupyterhub_config.py

