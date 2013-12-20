<%@ WebHandler Language="C#" Class="JGetReport" %>

using System;
using System.Web;

public class JGetReport : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        DateTime dt1,dt2;
        var error="";
        var item = context.Request["item"];
        var type = context.Request["type"];
        if (!DateTime.TryParse(context.Request["dt1"], out dt1))
            error = "Не задана дата начала\\n";
        if (!DateTime.TryParse(context.Request["dt2"], out dt2))
            error = "Не задана дата конца\\n";
        if(string.IsNullOrEmpty(item))
            error = "Не выбран объект для отчёта\\n";
        if (string.IsNullOrEmpty(type))
            type = "hour";
        if (string.IsNullOrEmpty(error))
        {
            var group = GetReport(dt1, dt2, item, type);
            context.Response.Write(group);
        }
        else
            context.Response.Write(string.Format("{{\"error\": \"{0}\"}}", error));
        
    }

    private string GetReport(DateTime dt1,DateTime dt2, string item, string type)
    {
        Db db = new Db();
        var temp = db.GetReport(dt1,dt2,item,type);
        return temp;
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}