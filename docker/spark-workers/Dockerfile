FROM gettyimages/spark:2.4.0-hadoop-3.0

# RUN apt-get -y update 
# RUN apt-get install --no-install-recommends -y tini libc6-compat linux-pam nss && \
#     rm -rf /var/lib/apt/lists/*
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini



RUN cp -R ${SPARK_HOME} /opt/spark

ENV SPARK_HOME /opt/spark
ENV SPARK_EXTRA_CLASSPATH ${SPARK_DIST_CLASSPATH}
ENV PYTHONPATH=/opt/spark/python/lib/pyspark.zip:/opt/spark/python/lib/py4j-*.zip

RUN mkdir -p ${SPARK_HOME}/work-dir
COPY entrypoint.sh /opt/

WORKDIR ${SPARK_HOME}/work-dir

ENTRYPOINT [ "/opt/entrypoint.sh" ]