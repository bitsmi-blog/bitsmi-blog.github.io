---
author: Antonio Archilla
title: Obtener la conexión a base de datos a través de Hibernate 4
date: 2015-03-30
categories: [ "references", "java", "persistence" ]
tags: [ "java", "hibernate4", "jasperreports" ]
layout: post
excerpt_separator: <!--more-->
---

Si estáis trabajando en una aplicación en la que la persistencia se hace a través de **Hibernate 4**, 
os habréis dado cuenta que ha desaparecido la posibilidad de obtener el objecto [`Connection`](http://docs.oracle.com/javase/6/docs/api/java/sql/Connection.html)
a través de la [`Session`](http://docs.jboss.org/hibernate/orm/4.1/javadocs/org/hibernate/Session.html) de **Hibernate**. 
Esto sucede porque en el paso de **Hibernate 3** a **Hibernate 4** ha desaparecido el método [`connection()`](http://docs.jboss.org/hibernate/orm/3.5/javadoc/org/hibernate/Session.html#connection()) 
a través del que se podía obtener.


El problema viene en el momento en que se necesita acceder directamente a la conexión para, por ejemplo, utilizar librerías como **Jasperreports** que necesitan de ella 
para rellenar los datos del reporte cuando la fuente es la base de datos directamente. Con **Hibernate 3** se hubiera podido acceder a ella directamente desde la **Session**, 
aunque en la versión **3.5** esta forma de obtenerla ya se encontraba deprecada, pero en **Hibernate 4** es necesario utilizar la nueva **API Work** de la siguiente manera:

<!--more-->

```java
import javax.persistence.EntityManager;
import org.hibernate.Session;
import org.hibernate.ejb.HibernateEntityManager;
import org.hibernate.jdbc.Work;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
  
// ...
  
try{            
    // Obtenemos el entityManager de JPA. En este caso viene inyectado
    HibernateEntityManager em = (HibernateEntityManager)entityManagerProvider.get();
    Session session = em.getSession();
    session.doWork(new Work() 
    {
        @Override
        public void execute(Connection connection) throws SQLException 
        {
            try{
                InputStream fileStream = getClass().getResourceAsStream(reportPath);
                JasperReport compiledReport = JasperCompileManager.compileReport(fileStream);
                JasperPrint jasperPrint = JasperFillManager.fillReport(compiledReport, reportParameters, connection);
                 
                // Visualizar o guardar el informe resultante
            }
            catch(JRException e){
                throw new RuntimeException(e);
            }
        }
    });                                                
}
catch(Exception e){            
    // Tratar el error
}
```
