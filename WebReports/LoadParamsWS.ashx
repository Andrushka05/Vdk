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
        
        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format("{0}(", context.Request["feedback"]));
        
        
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
        
		SqlCommand sqlCmd = new SqlCommand("SELECT id, params_name, joined_params FROM Trend_Store", sqlConn);
		sqlCmd.CommandTimeout = 30;
		SqlDataReader sqlReader = sqlCmd.ExecuteReader();
		
		int params_cntr = 0;
		string strRes = "{ \"data\" : [";
		
		while (sqlReader.Read()) {
			strRes += params_cntr > 0 ? "," : "";
			strRes += " {\"id\":\"" + sqlReader["id"].ToString() + "\", \"name\":\"" + sqlReader["params_name"].ToString() + "\", \"params\":\"" + sqlReader["joined_params"].ToString() + "\"} ";
			params_cntr++;
		}
		sqlReader.Close();
		strRes += "]}";
        
		if (params_cntr == 0)
			strRes = "{\"error\": \"Нет сохраненных наборов параметров\"}";
			
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