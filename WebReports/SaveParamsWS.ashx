<%@ WebHandler Language="C#" Class="LoadParamsWS" %>

using System;
using System.Web;
using System.Globalization;
using System.Xml;
using System.Data.SqlClient;

public class LoadParamsWS : IHttpHandler {
   
    public void ProcessRequest(HttpContext context) {
        System.IO.Directory.SetCurrentDirectory(context.Request.PhysicalApplicationPath);
        context.Response.ContentType = "application/x-javascript; charset:utf8";
        context.Response.ContentType = "text/plain; charset:utf8";
        string connectionString = "";
        string dbParams = "";
		string dbName = "";
		
        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format("{0}(", context.Request["feedback"]));
		
		try {
            dbParams = context.Request["params"];
			dbName = context.Request["name"];
        } catch (Exception exErr) {
            context.Response.Write(string.Format("{{\"error\": \"Ошибка при обработке параметров: {0}\"}}", exErr.Message));
			
			if (!string.IsNullOrEmpty(context.Request["feedback"]))
				context.Response.Write(string.Format(")", context.Request["feedback"]));
				
			return;
        }
        
        try {
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.Load("DiagrammCfg.xml");
            connectionString = xmlDoc["diagramm"]["dbConnectionString"].InnerText;
        } catch (Exception exErr) {
            context.Response.Write(string.Format("{{\"error\": \"Ошибка при открытии конфигурации: {0}\"}}", exErr.Message));
			
			if (!string.IsNullOrEmpty(context.Request["feedback"]))
				context.Response.Write(string.Format(")", context.Request["feedback"]));
				
			return;
        }
        
        SqlConnection sqlConn = new SqlConnection(connectionString);
		sqlConn.Open();
		SqlCommand sqlCmd = new SqlCommand("INSERT INTO Trend_Store (params_name, joined_params) VALUES ('" + dbName + "', '" + dbParams + "')", sqlConn);
		sqlCmd.CommandTimeout = 30;
		string strRes = "";
		
		if (sqlCmd.ExecuteNonQuery() > 0)
			strRes = "{ \"data\" : \"OK\" }";
		else
			strRes = "{ \"error\": \"Не удалось сохранить набор параметров в БД.\"} ";
		
        	
		context.Response.Write(strRes);
		
        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format(")", context.Request["feedback"]));
        
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }
}