<%@ WebHandler Language="C#" Class="JGetMenu" %>

using System;
using System.Web;

public class JGetMenu : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        var type = context.Request["type"];
        var group = GetGroup(type);
        context.Response.Write(group);
    }

    private string GetGroup(string type)
    {
        Db db = new Db();
        var temp = db.GetMenu(type);
        return temp;
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }
}