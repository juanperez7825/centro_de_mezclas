# EMOTION

## Tools and dumps

To start this project you will need the following elements:

- [SpringToolSuite4](https://spring.io/tools)
- [MariaDB](https://mariadb.com/kb/en/installing-mariadb-on-macos-using-homebrew/)
- [Apache Tomcat Server 8.5](https://tomcat.apache.org/download-80.cgi)
- [maven](https://maven.apache.org/install.html)
- [DB Dump](https://drive.google.com/drive/folders/17HwRgyQAJCi9R4h2T9xmZXZM_LmA5RUy)

> Feel free to change it for a docker version if you want.

## Modifications

Before you start your project you will face a couple of known issues with the `pom.xml`. In order to download all the required dependencies you will need to do the following modifications.

> It's important to mention that the following changes are to be applied only in your local environment and MUST avoid to commit/push any of these changes.

### pom.xml

```xml
254:-        <sonar.scm.provider>svn</sonar.scm.provider>
254:+        <!-- sonar.scm.provider>svn</sonar.scm.provider-->


426:-            <scope>provided</scope>
426:+            <!--<scope>provided</scope>-->

429:+        <!--Hibernate-->
430:+        <dependency>
431:+            <groupId>org.hibernate</groupId>
432:+            <artifactId>hibernate-validator</artifactId>
433:+            <version>5.2.4.Final</version>
434:+        </dependency>
435:+
436:+        <!--GlassFish-->
437:+        <dependency>
438:+            <groupId>javax.faces</groupId>
439:+            <artifactId>javax.faces-api</artifactId>
440:+            <version>2.3</version>
441:+        </dependency>
442:+        <dependency>
443:+            <groupId>org.glassfish</groupId>
444:+            <artifactId>javax.faces</artifactId>
445:+            <version>2.4.0</version>
446:+        </dependency>

703:-            <type>jar</type>
703:+            <!--type>jar</type-->

705:-        <dependency>
705:+        <!-- dependency>
........        <groupId>javax</groupId>
........        <artifactId>javaee-api</artifactId>
........        <version>6.0</version>
........        <type>jar</type>
710:-        </dependency>
710:+        </dependency-->


747:-            <plugin>
747:+            <!--plugin>
........            <groupId>org.codehaus.mojo</groupId>
........            <artifactId>buildnumber-maven-plugin</artifactId>
........            <version>1.4</version>
@@ -741,8 +760,8 @@
........            <doCheck>false</doCheck>
........            <doUpdate>false</doUpdate>
........         </configuration>
763:-            </plugin>
763:+            </plugin-->
```

After you have finished the modifications you'll be able to clean and compile the project with the following command

```
> mvn clean compile
```

### src/main/resources/config/appCxt.xml

Now it is turn to modify the application context as follows:

```xml
101:-   <-beans:bean id="dataSource2" class="org.springframework.jdbc.datasource.DriverManagerDataSource" >
101:+   <!--beans:bean id="dataSource2" class="org.springframework.jdbc.datasource.DriverManagerDataSource" >
.....       <beans:property name="driverClassName" value="${mssql.driverClassName}" />
.....       <beans:property name="url" value="${mssql.url}" />
.....       <beans:property name="username" value="${mssql.username}" />
.....       <beans:property name="password" value="${mssql.password}" />
106:-   </beans:bean>
106:+   </beans:bean-->

188:-   <beans:bean id="sqlSessionFactory2" class="org.mybatis.spring.SqlSessionFactoryBean" >
188:+   <!--beans:bean id="sqlSessionFactory2" class="org.mybatis.spring.SqlSessionFactoryBean" >
.....       <beans:property name="dataSource" ref="dataSource2" />
.....       <beans:property name="configLocation" value="classpath:mybatis-config.xml" />
.....       <beans:property name="databaseIdProvider" ref="databaseIdProvider" />
.....       <beans:property name="mapperLocations" value="classpath*:config/mappers2/**/*.xml" />
.....       <beans:property name="typeAliasesPackage" value="mx.com.avg.model" />
194:-   </beans:bean>
194:+   </beans:bean-->

197:-   <beans:bean id="mapperScannerConfigurer2" class="org.mybatis.spring.mapper.MapperScannerConfigurer">
197:+   <!--beans:bean id="mapperScannerConfigurer2" class="org.mybatis.spring.mapper.MapperScannerConfigurer">
.....       <beans:property name="basePackage" value="mx.com.avg.mapper" />
.....       <beans:property name="sqlSessionFactoryBeanName" value="sqlSessionFactory2" />
200:-   </beans:bean>
200:+   </beans:bean-->


208:-   <beans:bean id="transactionManager2" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
208:+   <!--beans:bean id="transactionManager2" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
.....       <beans:property name="dataSource" ref="dataSource2" ></beans:property>
210:-   </beans:bean>
210:+   </beans:bean-->
```

### src/main/resources/config.properties

Update your properties to match your JNDI tree

```properties
11:-    jdbc.mysql.datasource=jdbc/unidosis
11:-    jdbc.mysql.datasource=java:comp/env/jdbc/unidosis
```

### Maria Database

In case you are willing to Dockerize your DB you can use the following command to get maria and create a DB

```
> docker run -p 127.0.0.1:3306:3306 \
             --name hjm-dev-db \
             -e MARIADB_ROOT_PASSWORD=123456 \
             -e MARIADB_DATABASE=hjm-dev \
             -d mariadb:latest
```

And for connecting into the Dockerized Maria DB

```
> docker exec -it hjm-dev-db mariadb -uroot -p
```

Once you are done with the connection the next step is to dump the backup file which you previously donwloaed in the first step of this README. If you have followed this file so far you will need to run the following command:

```
> docker exec -i hjm-dev-db sh -c 'exec mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" hjm-dev' < /some/path/on/your/host/EHJ-DEV-DUMP.sql
```

### JDNI (Tomcat)

To create a JNDI resource in tomcat you will need to update the `context.xml` file  and add the folloing into it.

```
<Resource auth="Container" driverClassName="org.mariadb.jdbc.Driver" maxActive="8"
    maxIdle="4" type="javax.sql.DataSource" validationQuery="select 1"
    name="jdbc/unidosis" password="123456" username="root"
    url="jdbc:mariadb://localhost:3306/hjm-dev?allowMultiQueries=true"
/>
```

You will need to replace a few attributes in there like the name, username, password and url with the values of your preference but in general this is how a JDNI Resource looks like.

## Up and running

### Importing the project

Importing a project into STS/Eclipse is not something out of the world and if you have worked with Spring and Java this is something you should familiar with. However, is worth mentioning how to do it just in case.

- After you have downloaded the STS and the code base, open the STS and go to the `File` menu and select `Import...`.
- This option will open a pop-up (the import wizard) Here you will need to click in the `Maven -> Existing Maven Projects` option.
- Then browse the project base code and open it.
- After that the `pom.xml` should be listed in `Projects` area.
- Finally click on the Finish button.

Right after you click on the Finish button maven will download all the dependencies required for the project (this usually takes a while).

### Server and Deploy

STS has a built-in feature for configuring an application server for enabling it in your environment you will need the `Servers View`.
To show this View you will need to click in the `Window` Menu then `Show View` option and selecting `Other...`. After clicking it a pop-up will appear and look for the `Server/Servers` option then click it.
Once the View is active click on the `No servers are available. Click this link to create a new server...` link displayed on it. That will open a new pop-up then click in the `Apache/Tomcatv8.5 Server` option and go to the Next step.

Now, if you already have imported the project into the workspace you will see the project listed in the Available resources section. Select it, then click in the `Add >` button and finally Finish the wizard.

After finishing the process it is time to run the server and the application. Right click on the Tomcat v8.5 Server in the Servers View and select `Start`

If everything goes well you should be able to see the main page at [http://localhost:8080/emotion/](http://localhost:8080/emotion/)

Default login credentials:

```
username: sadmin
password: nimda
```

## References
- [Ambiente Local MUS](https://docs.google.com/document/d/1MrSWdcG6WF9hHEWGBzPkONPs8rk-9ov9rUDqhq4WP8I/edit)
