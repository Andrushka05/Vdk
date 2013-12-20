using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Сводное описание для FlotPoint
/// </summary>
public class FlotPoint
{
    public string Time { get; set; }
    public double Value { get; set; }
    public override string ToString()
    {
        var res = string.Format("[\"{0}\",{1}]", Time, Value);
        return res;
    }
}