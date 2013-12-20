using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;

/// <summary>
/// Работа с Db
/// </summary>
public class Db
{
    private const string connect = "Password=27cQ98n;Persist Security Info=True;User ID=LoggersVDK;Initial Catalog=Pskov;Data Source=192.168.8.15;";
    public readonly string nameTable;
    public Db()
    {
        nameTable = "_rep";
    }

    /// <summary>
    /// </summary>
    /// <param name="nameTable">Название таблицы в БД</param>
    public Db(string nameTable)
    {
        this.nameTable = nameTable;
    }

    /// <summary>
    /// Получить список групп
    /// </summary>
    /// <returns>Json строка</returns>
    public string GetGroup()
    {
        var response = GetContext("select * from " + nameTable);
        try
        {
            var temp = (from System.Data.IDataRecord r in response
                        select new { Name = r["g_name"], Id = r["g_id"] }).Distinct().ToList(); //new TypeVdk() { Name=r["name"].ToString(), FullName = r["name"].ToString() + " " + r["title"].ToString(), Id = r["id"].ToString() }).ToList();
            var res = JsonConvert.SerializeObject(temp);
            return res;
        }
        catch (Exception ex)
        {
            //log
            throw ex;
        }
    }

    /// <summary>
    /// Получить список типов
    /// </summary>
    /// <param name="nameGroup">Название группы, из которой нужно выбрать все типы</param>
    /// <returns>Json строка</returns>
    public string GetItem(string nameGroup)
    {
        var response = GetContext("select * from " + nameTable);
        try
        {
            var temp = (from System.Data.IDataRecord r in response
                        where r["g_name"].ToString() == nameGroup
                        select new { Name = r["i_name"], Id = r["i_id"] }).ToList(); //new TypeVdk() { Name=r["name"].ToString(), FullName = r["name"].ToString() + " " + r["title"].ToString(), Id = r["id"].ToString() }).ToList();
            var res = Newtonsoft.Json.JsonConvert.SerializeObject(temp);
            return res;
        }
        catch (Exception ex)
        {
            //log
            throw ex;
        }
    }

    public string GetReport(DateTime dt1, DateTime dt2, string item, string type)
    {
        //Внс "[_select_{vns}] '{2:yyMMdd HH:00}', '{3:yyMMdd HH:00}',{type},{id}}'"
        var id = Regex.Replace(item, @"[^\d]", "");
        item = item.Replace(id, "");
        var request = string.Format("[_select_{0}] '{1:yyMMdd HH:00}', '{2:yyMMdd HH:00}', {3}, '{4}'",item, dt1, dt2, type == "day" ? 1 : 0, id);
        var ds = GetDataSet(request);
        var json = JsonConvert.SerializeObject(JsonConvert.SerializeObject(ds));
        return json;
    }

    public string GetMenu(string type)
    {
        var request = string.Format("[_select_menu] {0}",type);
        var ds = GetDataSet(request);
        var json = JsonConvert.SerializeObject(JsonConvert.SerializeObject(ds));
        return json;
    }

    public string GetDataChart(string dt1, string dt2, string iId, string propId)
    {
        DateTime dT1,dT2;
        var b = DateTime.TryParse(dt1,out dT1);
        if (!b)
            return "Ошибка даты 1";
        b = DateTime.TryParse(dt2,out dT2);
        if (!b)
            return "Ошибка даты 2";
        var request = string.Format("[_select_chart] '{0:yyMMdd HH:00}', '{1:yyMMdd HH:00}', '{2}', '{3}'", dT1,dT2,iId,propId);
        var ds = GetDataSet(request);
        var json = JsonConvert.SerializeObject(JsonConvert.SerializeObject(ds));
        return json;
    }

    private SqlDataReader GetContext(string request)
    {
        try
        {
            SqlConnection sqlConn = new SqlConnection(connect);
            sqlConn.Open();
            var sqlCmd = new SqlCommand(request,sqlConn);
            sqlCmd.CommandTimeout = 30;
            var sqlReader = sqlCmd.ExecuteReader();
            return sqlReader;
        }
        catch (Exception ex)
        {
            //log
            throw ex;
        }
    }

    private DataSet GetDataSet(string request)
    {
        try
        {
            SqlDataAdapter adapter = new SqlDataAdapter(request, connect);
            DataSet ds = new DataSet();
            adapter.Fill(ds);
            return ds;
        }
        catch (Exception ex)
        {
            //log
            throw ex;
        }
    }
}