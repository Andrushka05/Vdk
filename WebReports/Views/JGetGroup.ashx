<%@ WebHandler Language="C#" Class="JGetGroup" %>

using System;
using System.Web;

public class JGetGroup : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        var group = GetGroup();
        context.Response.Write(group);
    }

    private string GetGroup()
    {
        Db db = new Db();
        var temp = db.GetGroup();
        return temp;
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}