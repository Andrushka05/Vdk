<%@ WebHandler Language="C#" Class="webservices" %>

using System;
using System.Web;
using System.Web.Configuration;
using System.Data.SqlClient;

public class webservices : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {

        context.Response.ContentType = "application/octet-stream";
        string connectionString =
            WebConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;



        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format("{0}(", context.Request["feedback"]));
        
        if (string.IsNullOrEmpty(context.Request["cmd"])) {
            context.Response.Write(string.Format("{{\"error\": \"{0}\"}}", "Отсуствует команда"));
            return;
        }

        
        string command = context.Request["cmd"].ToLower();
        SqlConnection sqlConn = new SqlConnection(connectionString);
        SqlCommand sqlCmd = new SqlCommand(null, sqlConn);
        SqlDataReader sqlReader;
        sqlConn.Open();

        
        switch (command) {
            case "init":
                             
                int lastHours = 0;
                if (string.IsNullOrEmpty(context.Request["assi"]) || string.IsNullOrEmpty(context.Request["hours"]) ||
                    !int.TryParse(context.Request["hours"], out lastHours)) {
                        context.Response.Write(string.Format("{{\"error\": \"{0}\"}}", "Неверные аргументы команды"));
                    break;
                }

                sqlCmd.CommandText = string.Format("select_assi_trend '{0}', '{1:yyMMdd HH:mm:ss}'", context.Request["assi"], 
                    DateTime.Now.AddHours(-lastHours));

                sqlReader = sqlCmd.ExecuteReader();
                context.Response.Write("{\"data\" : [");
                bool isFirst = true;
                while (sqlReader.Read()) {
                    if (!isFirst) context.Response.Write(",");
                    double timeStamp = ((DateTime)sqlReader["dt"] - DateTime.Parse("01.01.1970 00:00")).TotalMilliseconds;
                    context.Response.Write(string.Format("[\"{0}\", {1}]", timeStamp, sqlReader["press"].ToString().Replace(',', '.')));
                    isFirst = false;                   
                }
                context.Response.Write("]}");
                
                break;
            case "get":
                
                break;
            default:
                context.Response.Write(string.Format("{{\"error\": \"{0}\"}}", "Команда не распознана"));
                break;
        }
        
        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format(")", context.Request["feedback"]));
        
        sqlConn.Close();
        
        
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}