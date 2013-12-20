<%@ WebHandler Language="C#" Class="JGetItem" %>

using System;
using System.Web;

public class JGetItem : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        var nameGroup = context.Request["group"];
        var types = GetItem(nameGroup);
        context.Response.Write(types);
    }

    private string GetItem(string group)
    {
        Db db = new Db();
        var temp = db.GetItem(group);
        return temp;
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}