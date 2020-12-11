#!/bin/bash
# Install OpenJDK / Scala
apt-get install openjdk-11-jdk-headless -qq > /dev/null

curl https://downloads.lightbend.com/scala/${scala_version}/scala-${scala_version}.deb -k -o scala.deb
apt install -y ./scala.deb
rm -rf scala.deb /var/lib/apt/lists/*

# Install Spark & Hadoop
curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz -o spark.tgz
tar -xf spark.tgz
mv spark-${spark_version}-bin-hadoop${hadoop_version} /usr/bin/
echo "alias pyspark=/usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/bin/pyspark" >> ~/.bashrc
echo "alias spark-shell=/usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/bin/spark-shell" >> ~/.bashrc
mkdir /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/logs
rm spark.tgz

wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/3.2.0/hadoop-azure-3.2.0.jar
mv hadoop-azure-3.2.0.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

wget https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage/8.4.0/azure-storage-8.4.0.jar
mv azure-storage-8.4.0.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.35.v20201120/jetty-util-9.4.35.v20201120.jar
mv jetty-util-9.4.35.v20201120.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util-ajax/9.4.35.v20201120/jetty-util-ajax-9.4.35.v20201120.jar
mv jetty-util-ajax-9.4.35.v20201120.jar /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars

cat <<EOT >> core-site.xml 
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>fs.azure.account.key.${storage_account}.blob.core.windows.net</name>
		<value>${account_key}</value>
	</property>
</configuration>
EOT

mv core-site.xml /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/conf/