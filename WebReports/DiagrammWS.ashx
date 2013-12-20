<%@ WebHandler Language="C#" Class="DiagrammWS" %>

using System;
using System.Web;
using System.Globalization;
using System.Xml;
using System.Data.SqlClient;
using System.Linq;
public class DiagrammWS : IHttpHandler {

    public static string connectionString;
    
    public void ProcessRequest(HttpContext context) {
        System.IO.Directory.SetCurrentDirectory(context.Request.PhysicalApplicationPath);
        context.Response.ContentType = "application/x-javascript; charset:utf8";
        context.Response.ContentType = "text/plain; charset:utf8";

        DateTime dt1;
        DateTime dt2;
        string[] dbParams = new string[0];
        bool hour = false;
        string errorMessage = string.Empty;

        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format("{0}(", context.Request["feedback"]));

        if (!DateTime.TryParse(context.Request["dt1"], out dt1))
            errorMessage += "Не задана дата начала\\n";
        if (!DateTime.TryParse(context.Request["dt2"], out dt2))
            errorMessage += "Не задана дата окончания\\n";
        
        Boolean.TryParse(context.Request["hour"], out hour);
       
        try {
            dbParams = context.Request["params"].Split('|');
        } catch {
            errorMessage += "Ошибка при разборе параметров\\n";
        }
        
        if (errorMessage == string.Empty) {
            context.Response.Write(genDiagrammData(dt1, dt2,dbParams,hour));
            
        } else
            context.Response.Write(string.Format("{{\"error\": \"{0}\"}}", errorMessage));


        if (!string.IsNullOrEmpty(context.Request["feedback"]))
            context.Response.Write(string.Format(")", context.Request["feedback"]));
    }

    private string genDiagrammData(DateTime dt1, DateTime dt2, string[] dbParam, bool hour) {

       
        string strRes = string.Empty;
        string[] arrStr = new string[dbParam.Length];
        float fTmp;
        try {
            if (string.IsNullOrEmpty(connectionString)) {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load("DiagrammCfg.xml");
                connectionString = xmlDoc["diagramm"]["dbConnectionString"].InnerText;
            }
        } catch (Exception exErr) {
            return string.Format("{{\"error\": \"Ошибка при открытии конфигурации: {0}\"}}", exErr.Message);
        }


        var exceptions = new System.Collections.Concurrent.ConcurrentQueue<Exception>();
        try {
            
            
            /*
            sqlCmd = new SqlCommand("UPDATE Trend_Store SET joined_params='" + String.Join("|", dbParam) + "'", sqlConn);
            if (sqlCmd.ExecuteNonQuery() < 1)
            {
                sqlCmd.CommandText = "INSERT INTO Trend_Store (joined_params) VALUES ('" + String.Join("|", dbParam) + "')";
                sqlCmd.ExecuteNonQuery();
            }
            sqlCmd.Dispose();
            */
            
            System.Collections.Generic.List<TimeSpan> sts = new System.Collections.Generic.List<TimeSpan>();
            //double timeStamp;
            System.Threading.Tasks.Parallel.For(0, dbParam.Length, i =>
            {
                SqlCommand sqlCmd;
                SqlDataReader sqlReader;
                SqlConnection sqlConn = new SqlConnection(connectionString);
                sqlConn.Open();
                string[] gP = dbParam[i].Split('*');
                var f = "select_vns_analog select_teleskop_analog select_teleskop_Zud_analog";
                sqlCmd = new SqlCommand(string.Format("[{0}] '{2:yyMMdd HH:mm:ss}', '{3:yyMMdd HH:mm:ss}', '{1}'", gP[0], gP[1], dt1, dt2), sqlConn);
                sqlCmd.CommandTimeout = 30;
                sqlReader = sqlCmd.ExecuteReader();
                System.Collections.Generic.List<FlotPoint> list = new System.Collections.Generic.List<FlotPoint>();
                var date1970 = DateTime.Parse("01.01.1970 00:00");

                if (hour)
                {
                    var Minlists = (from System.Data.IDataRecord r in sqlReader
                                    group r by new { ((DateTime)r["sysdate"]).Year, ((DateTime)r["sysdate"]).DayOfYear, ((DateTime)r["sysdate"]).Hour } into g
                                    let av = g.Average(x => Single.Parse((x[gP[2]]).ToString()))
                                    let min = g.Min(x => Single.Parse((x[gP[2]]).ToString()))
                                    where av / 2 > min
                                    let sysDate = ((DateTime)g.FirstOrDefault()["sysdate"]).ToUniversalTime()
                                    let d = new DateTime(sysDate.Year, sysDate.Month, sysDate.Day, sysDate.Hour, 0, 0)
                                    select new FlotPoint()
                                    {
                                        Value = Math.Round(min, 2),
                                        Time = ((long)((d - date1970).TotalMilliseconds)).ToString()
                                    }).ToList();
                    sqlReader.Close();
                    sqlReader = sqlCmd.ExecuteReader();
                    var Maxlists = (from System.Data.IDataRecord r in sqlReader
                                    group r by new { ((DateTime)r["sysdate"]).Year, ((DateTime)r["sysdate"]).DayOfYear, ((DateTime)r["sysdate"]).Hour } into g
                                    let av = g.Average(x => Single.Parse((x[gP[2]]).ToString()))
                                    let max = g.Max(x => Single.Parse((x[gP[2]]).ToString()))
                                    where av * 1.5 < max
                                    let sysDate = ((DateTime)g.FirstOrDefault()["sysdate"]).ToUniversalTime()
                                    let d = new DateTime(sysDate.Year, sysDate.Month, sysDate.Day, sysDate.Hour, 0, 0)
                                    select new FlotPoint()
                                    {
                                        Value = Math.Round(max, 2),
                                        Time = ((long)((d - date1970).TotalMilliseconds)).ToString()
                                    }).ToList();
                    sqlReader.Close();
                    sqlReader = sqlCmd.ExecuteReader();
                    var Avlist = (from System.Data.IDataRecord r in sqlReader
                                  group r by new { ((DateTime)r["sysdate"]).Year, ((DateTime)r["sysdate"]).DayOfYear, ((DateTime)r["sysdate"]).Hour } into g
                                  let sysDate = ((DateTime)g.FirstOrDefault()["sysdate"]).ToUniversalTime()
                                  let d = new DateTime(sysDate.Year, sysDate.Month, sysDate.Day, sysDate.Hour, 0, 0)
                                  select new FlotPoint()
                                  {
                                      Value = Math.Round(g.Average(x => Single.Parse((x[gP[2]]).ToString())), 2),
                                      Time = ((long)((d - date1970).TotalMilliseconds)).ToString()
                                  }).ToList();
                    list = Minlists.Union(Maxlists).Union(Avlist).OrderBy(x => x.Time).Distinct().ToList();
                    if (list[0].Time != ((dt1 - date1970).TotalMilliseconds).ToString())
                        list.Insert(0, new FlotPoint() { Value = 0, Time = ((dt1 - date1970).TotalMilliseconds).ToString() });
                }else
                {
                    list = (from System.Data.IDataRecord r in sqlReader
                            where r[gP[2]] != null //&& (double)r[gP[2]] > -0.001
                            select new FlotPoint()
                            {
                                Value = Math.Round(Double.Parse((r[gP[2]]).ToString()),2),
                                Time = ((long)((((DateTime)sqlReader["sysdate"]).ToUniversalTime() - date1970).TotalMilliseconds)).ToString()
                            }).ToList();
                }
                
                sqlReader.Close();
                if (list.Any())
                {
                    var str = "\"Value\":";
                    var str2 = "\"Time\":";
                    //var c = list.Count / 30000;
                    //for (int j = 0, z = 0; z <= c + 1; z++)
                    //{
                    //    arrStr[i] += new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(list.GetRange(j, z >= c || c == 0 ? list.Count % 30000 : 30000)).Replace(str, "").Replace(str2, "").Replace("{", "[").Replace("}", "]");
                    //    if (c == 0)
                    //        break;
                    //    j = +30000;
                    //}
                    var json = Newtonsoft.Json.JsonConvert.SerializeObject(list.ToArray()).Replace(str, "").Replace(str2, "").Replace("{", "[").Replace("}", "]");
                    arrStr[i] = json.Substring(1, json.Length - 2);
                }
            //}

                //catch (Exception e) { exceptions.Enqueue(e); }
            });

            
            strRes += "{ \"data\" : [";
            for (int i = 0; i < dbParam.Length; i++) {
                strRes += string.Format(NumberFormatInfo.InvariantInfo, "{0} {{\"label\":\"" + dbParam[i] + "\", \"data\":[{1}] }}", i > 0 ? "," : "", arrStr[i]);
            }

            strRes += "]}";
            if (exceptions.Count > 0) throw new AggregateException(exceptions);

        } catch (Exception exErr) {
            return string.Format("{{\"error\": \"Ошибка при получении данных: {0}\"}}", exErr.Message);
        }
        return strRes;
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}