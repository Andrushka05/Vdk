<%@ WebHandler Language="C#" Class="JGetDataChart" %>

using System;
using System.Web;

public class JGetDataChart : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        var dt1 = context.Request["dt1"];
        var dt2 = context.Request["dt2"];
        var iId=context.Request["iid"];
        var propId = context.Request["propid"];
        var data = GetItem(dt1,dt2,iId,propId);
        context.Response.Write(data);
    }

    private string GetItem(string dt1,string dt2,string iId,string propId="")
    {
        Db db = new Db();
        var temp = db.GetDataChart(dt1,dt2,iId,propId);
        return temp;
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}