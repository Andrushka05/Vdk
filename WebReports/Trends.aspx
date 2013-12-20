<%@ Page Language="C#" MasterPageFile="~/MasterPage.master"%>
<asp:Content ID="Content1" ContentPlaceHolderID="headerTempl" runat="Server">
<script runat="server">

    private int __count;
    private string __js;
    private bool __isFirst;
    //private string __restoredTrends;
    
    private void onCreateMenu(System.Xml.XmlNode xmlEl, HtmlGenericControl htmlItem) {
            
        string sp;
        string param;
        string db;
        
        for (int i = 0; i < xmlEl.ChildNodes.Count; i++) {

            if (xmlEl.ChildNodes[i].Name == "item" || xmlEl.ChildNodes[i].Name == "items") {

                HtmlGenericControl el = new HtmlGenericControl("li");
                HtmlGenericControl linkEl = new HtmlGenericControl("a");
                linkEl.InnerText = xmlEl.ChildNodes[i].Attributes["name"].InnerText;
                el.Controls.Add(linkEl);
                if (xmlEl.ChildNodes[i].Name == "items") {
                    HtmlGenericControl innerElement = new HtmlGenericControl("ul");
                    onCreateMenu(xmlEl.ChildNodes[i], innerElement);
                    el.Controls.Add(innerElement);
                } else {
                    el.Attributes.Add("id", "idEl_" + __count++);

                    sp = xmlEl.ChildNodes[i].Attributes["sp"] != null ? xmlEl.ChildNodes[i].Attributes["sp"].InnerText : "";
                    param = xmlEl.ChildNodes[i].Attributes["param"] != null ? xmlEl.ChildNodes[i].Attributes["param"].InnerText : "";
                    db = xmlEl.ChildNodes[i].Attributes["db"] != null ? xmlEl.ChildNodes[i].Attributes["db"].InnerText : "";

                    if (!__isFirst)
                        __js += ",";
                    __isFirst = false;
                    __js += "{ sp : \"" + sp + "\", param : \"" + param + "\", db : \"" + xmlEl.ChildNodes[i].Attributes["db"].InnerText + "\" }";
                    
                    
                    el.Attributes.Add("class", "addLineItem");
                }
                htmlItem.Controls.Add(el);
            }
        }
        
    }

    protected override void OnLoad(EventArgs e) {

        AddLineMenu.Controls.Clear();
        __count = 0;
        __js = "";
        __isFirst = true;
        //__restoredTrends = "";
        
        System.IO.Directory.SetCurrentDirectory(Request.PhysicalApplicationPath);
        System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument();
        xmlDoc.Load("DiagrammCfg.xml");


        onCreateMenu(xmlDoc["diagramm"]["items"], AddLineMenu);

        /*
        try
        {
            System.Data.SqlClient.SqlConnection sqlConn = new System.Data.SqlClient.SqlConnection(xmlDoc["diagramm"]["dbConnectionString"].InnerText);
            System.Data.SqlClient.SqlCommand sqlCmd = new System.Data.SqlClient.SqlCommand("SELECT TOP 1 joined_params FROM Trend_Store", sqlConn);
            System.Data.SqlClient.SqlDataReader sqlReader;
            sqlConn.Open();
            sqlReader = sqlCmd.ExecuteReader();
            if (sqlReader.Read())
                __restoredTrends = (String)sqlReader["joined_params"];

            sqlReader.Close();
        }
        catch (Exception ex)
        {
            __restoredTrends = "";
            // __restoredTrends = ex.Message;
        }
        */
        /*
        DateTime dt1 = DateTime.Now;
        System.Threading.Thread.Sleep(1500);
        DateTime dt2 = DateTime.Now;
        if (dt1 > dt2)
            Response.Write("dt1 = " + dt1.ToString() + " dt2 = " + dt2.ToString());
        else
            Response.Write("dt2 = " + dt2.ToString() + " dt1 = " + dt1.ToString());
        */
        base.OnLoad(e);
    }
</script>


    <link type="text/css" href="./js/jquery-ui-1.10.0.custom.css" rel="stylesheet" />
     <!--[if IE]><script type="text/javascript" src="flot/excanvas.min.js"></script><![endif]-->
    
    <script type="text/javascript" src="js/jquery.ui.datepicker-ru.js"></script>
    <script type="text/javascript" src="js/jquery.timepicker.js"></script>
<script type="text/javascript" src="js/jquery.event.drag-2.2.js"></script>
<script type="text/javascript" src="/js/jquery.mousewheel.js"></script>

    <script type="text/javascript" src="./flot/jquery.flot.js"></script>   
     
    <script type="text/javascript" src="./flot/jquery.flot.crosshair.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.navigate.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.selection.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.time.js"></script>
    <script type="text/javascript" src="flot/date.js"></script>

    

    <style type="text/css" media="all">
        
        #header {
            background: #ccc;
            padding: 4px 10px;
            overflow: hidden;
        }

        #body {
            padding:8px 30px 1px 37px;
        }

        .cmdPanel {
            float: left;
        }
        
        .cmdPanel2 {
            float: left;
            margin-left: 140px;
        }
		
		.cmdPanel3 {
            float: left;
            margin-left: 50px;
			display: none;
        }
		
		.cmdPanel4 {
            float: left;
            margin-left: 50px;
			display: none;
        }
		
		.cmdPanel button, .cmdPanel2 button, .cmdPanel3 button, .cmdPanel4 button
		{
			outline: 0px;
			-moz-user-select: none;
			-khtml-user-select: none;
			user-select: none; 
		}

        .timePanel {
            margin: 0px 0px 0px 100px;
            float: left;
        }

        #diagramm {
            width: 100%;
            height: 600px;
            margin-top: 10px;
        }

        #AddLineMenu {
            position: absolute;
            top: 10px;
            left: 10px;
        }

        .ui-menu {
            width: 250px;
        }

        #loadIcon {
            position: absolute;
            top: 100px;
            left: 100px;
        }

        #footer {
            margin: auto 0px 0px 0px;
            height: 20px;
        }
    </style>
    <style media="print" type="text/css">
        #header, #footer {
            display: none;
        }

        #body {
            padding: 0px;
        }

    </style>

    <style type="text/css">
        #legendContainer {
            background-color: #fff;
            padding: 2px;
            margin-top: 8px;
            margin-left: 4px;
            border-radius: 3px 3px 3px 3px;
            border: 1px solid #E6E6E6;
            display: inline-block;
        }
        #backgr {
            background-color: #FAF9CF;
            border-color: #CCCCCC;
            border-radius: 3px 3px 3px 3px;
            border-style: solid;
            border-width: 1px;
        }
        #slider {
            height: 200px;
            margin-left: 12px;
            margin-top: 200px;
        }
        #pSlide{
            float: left;
        }
        #amount{
            border: 0; 
            color: #f6931f; 
            font-weight: bold;
            width:20px;
            margin-left:15px;
        }
        
    </style>
   
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="bodyTempl" runat="Server">
    <div id="header">
        <div class="cmdPanel">
            <button id="showAddLine" style="width: 28px; height: 28px; background: url(./images/bar_chart_add_4047.png) no-repeat" title="Добавить график"></button>
            <!--<button style="width: 28px; height: 28px; background: url(./images/ruler1_4238.png) no-repeat" title="Линейка"></button>-->
            <button id="lineClearButton" style="width: 28px; height: 28px; background: url(./images/edit-clear_7607.png) no-repeat" title="Очистить"></button>
            <button style="width: 28px; height: 28px; background: url(./images/printer1_1706.png) no-repeat" title="Печать" onclick="window.print()"></button>
			<button id="resetDates"style="width: 28px; height: 28px; background: url(./images/48_hours.png) no-repeat" title="Сбросить даты на последние 48 часов"></button>
			<button id="zoomIn" style="width: 28px; height: 28px; background: url(./images/zoom_in.png) no-repeat" title="Увеличить масштаб"></button>
			<button id="zoomOut"style="width: 28px; height: 28px; background: url(./images/zoom_out.png) no-repeat" title="Уменьшить масштаб"></button>
			<button style="width: 28px; height: 28px; background: url(./images/zoom_reset.png) no-repeat" title="Сбросить масштаб" onclick="ResetZoom()"></button>
            <button   title="По суточное сравнение" onclick="GraphComp()">Сравнение</button>
        </div>
        <div class="timePanel">
            c:
            <input id="datepicker1" value="<%=DateTime.Now.AddDays(-2).ToString("dd.MM.yyyy HH:mm") %>" />
            по: 
            <input id="datepicker2" value="<%=DateTime.Now.ToString("dd.MM.yyyy HH:mm") %>" />
        </div>
        <div class="cmdPanel2">
            <button style="width: 28px; height: 28px; background: url(./images/load_params.png) no-repeat" title="Загрузить список параметров" onclick="LoadShowParams();"></button>
            <button id="SaveParamsBut" style="width: 28px; height: 28px; background: url(./images/save_params.png) no-repeat" title="Сохранить список параметров"></button>
        </div>
		<div class="cmdPanel3">
			Выберите набор параметров&nbsp;&nbsp;
			<select id="SavedParamsList" style="width: 150px;">
			</select>
			<button id="but_LoadTrend" style="width: 90px; height: 24px; display: none;" title="Загрузить">Загрузить</button>
			<button id="but_CancelLoadTrend" style="width: 90px; height: 24px; display: none;" title="Отмена" onclick="CancelLoad();">Отмена</button>
		</div>
		<div class="cmdPanel4">
			Введите имя&nbsp;&nbsp;
			<input type="text" id="SaveParamsName" style="width: 200px;" value="" />
			<button id="but_SaveParams" style="width: 90px; height: 24px;" title="Сохранить">Сохранить</button>
			<button id="but_CancelSaveParams" style="width: 90px; height: 24px;" title="Отмена" onclick="CancelSave();">Отмена</button>
		</div>
    </div>
    <div>
    <div id="pSlide">
    <div id="slider"></div>
    <input type="text" id="amount"/>
    </div>
    <div id="body">
        
        <div id="backgr">
        <div id="legendContainer"></div>
        <div id="diagramm"></div>
        </div>
        
        <script type="text/javascript">
        //____________________________________
        	//var options = {
        	//    series: { shadowSize: 0 },
        	//    lines: { show: true },
			//	points: { show: true },
			//	xaxis: { mode: "time", timeformat: "%h:%M:%S<br />%d.%m.%y", timezone: "utc" },
			//	//yaxis: {zoomRange:[1,1]},
			//	selection: { mode: "xy" },
			//	zoom: { interactive: true },
			//	pan: { interactive: true }
				
			//};
			
			var graph_data = null; // Данные для построения графиков
			var plot = null; // Объект график
			//______________________________
			function LoadShowParams()
			{
				CancelSave();
				$(".cmdPanel3").show();
				$("#SavedParamsList").html("");
				
				$.ajax({
					url: "./LoadParamsWS.ashx",
					method: 'GET',
					dataType: 'json',
					success: ParamsLoaded,
					timeout: 30000,
					error: onLoadparamsError
				});
				return false;
			}
						
			// Сброс масштаба
			function ResetZoom()
			{
				if (graph_data != null)
					plot = $.plot($("#diagramm"), graph_data, options);
			}
			
				
			function FormatStrNumber(in_val)
			{
				return in_val < 10 ? '0' + in_val : in_val;
			}
			
			function ParamsLoaded(recv_data)
			{
				if (recv_data.error) {
					alert(recv_data.error);
					$(".cmdPanel3").hide();
					$("#SavedParamsList").html("");
					return;
				}
				
				if (recv_data.data)
				{
					var data = recv_data.data;
					var par_list_html = "";
					for (i = 0; i < data.length; i++) {
						par_list_html += "<option id=\"" + data[i].id + "\" value=\"" + data[i].params + "\">" + data[i].name + "</option>";
					}
					$("#SavedParamsList").html(par_list_html);
					
					$("#but_LoadTrend").show();
					$("#but_CancelLoadTrend").show();
				}
				else
				{
					alert("Сервер вернул некорректный ответ");
					$(".cmdPanel3").hide();
					$("#SavedParamsList").html("");
					return;
				}
			}
			
			function onLoadparamsError() {
				//$.plot($("#diagramm"), [], options);
				alert("Не удалось загрузить список параметров");
				$(".cmdPanel3").hide();
				$("#SavedParamsList").html("");
			}
			
			function CancelLoad()
			{
				$(".cmdPanel3").hide();
				$("#SavedParamsList").html("");
				$("#but_LoadTrend").hide();
				$("#but_CancelLoadTrend").hide();
			}
			
			function CancelSave()
			{
				$(".cmdPanel4").hide();
				//$("#SaveParamsName").val("");
			}

			
            $(function () {
                var paramsList = new Array();
                var plot;
                var timeout = null;
                var isLock = false;
                var hour = false;
                var options = {
                    series: { shadowSize: 0 },
                    legend: {
                        container: $("#legendContainer"),
                        noColumns: 0,
                        labelFormatter: function (label, series) {
                            var cb = '<input class="legendCB" type="checkbox" ';
                            if (series.data.length > 0) {
                                cb += 'checked="true" ';
                            }
                            //var temp = $.trim(label.substr(0, label.indexOf("|")));
                            cb += ' id="' + label + '" /> ';
                            cb += label;
                            return cb;
                        }
                    },
                    lines: { show: true },
                    points: { show: true, radius: 1 },
                    xaxis: {
                        mode: "time",
                        timeformat: "%h:%M:%S<br />%d.%m.%y",
                        max: new Date().getTime() + 1000 * 60 * 60 * 5,
                        min: new Date().getTime() - 1000 * 60 * 60 * 24 * 2,
                        timezone: null
                    },
                    yaxis: {
                        zoomRange: false
                    },
                    zoom: { interactive: true },
                    pan: { interactive: true }
                };

                
                $("#slider").slider({
                    orientation: "vertical",
                    range: "min",
                    min: 0,
                    max: 10,
                    value: 5,
                    step: 1,
                    change: function (event, ui) {
                        var axes = $.plot($("#diagramm"), data, options).getAxes();
                        var range = axes.yaxis.max - axes.yaxis.min;

                        var arr = [1, 0.2, 0.3, 0.4, 0.5, 0.75];
                        var a = arr[Math.abs(5 - ui.value)];
                        var res =0;
                        if (ui.value > 5) {
                            res = (range * a) / 2;
                            plot = $.plot($("#diagramm"), data,
                            $.extend(true, {}, options, {
                                yaxis: { min: axes.yaxis.min + res, max: axes.yaxis.max - res }
                                })
                            );
                        }
                        else if (ui.value < 5) {
                            res = range * (a + 1) / 2;
                            plot = $.plot($("#diagramm"), data,
                            $.extend(true, {}, options, {
                                yaxis: { min: axes.yaxis.min, max: axes.yaxis.max + res }
                                })
                            );
                        }
                        $('#legendContainer').find("input").click(function () { setTimeout(plotByChoice, 100); });
                    },
                    slide: function (event, ui) {
                        $("#amount").val(ui.value);
                    }
                });
                $("#amount").val($("#slider").slider("value"));

                $("#datepicker1").datetimepicker({
                    dateFormat: "dd.mm.yy",
                    onSelect: function (dateText) {
                        onGetData();
                    }
                });
                $("#datepicker2").datetimepicker({
                    dateFormat: "dd.mm.yy",
                    onSelect: function (dateText) {
                        onGetData();
                    }
                });

                $("#resetDates").click(function () {
                    var dt1 = new Date();
                    dt1.setDate(dt1.getDate() - 2);
                    var dt1str = FormatStrNumber(dt1.getDate()) + '.' + FormatStrNumber(dt1.getMonth() + 1) + '.' + dt1.getFullYear() + ' ' + FormatStrNumber(dt1.getHours()) + ':' + FormatStrNumber(dt1.getMinutes());
                    $("#datepicker1").val(dt1str);

                    var dt2 = new Date();
                    var dt2str = FormatStrNumber(dt2.getDate()) + '.' + FormatStrNumber(dt2.getMonth() + 1) + '.' + dt2.getFullYear() + ' ' + FormatStrNumber(dt2.getHours()) + ':' + FormatStrNumber(dt2.getMinutes());
                    $("#datepicker2").val(dt2str);

                    onSend();

                });

                

                
                var data = [];
                var db = [<%=__js%>];
                
                $("#diagramm").bind('plotzoom', function (event, ranges) {
                    $('#legendContainer').find("input").click(function () { setTimeout(plotByChoice, 100); });
                });
                $("#diagramm").bind('plotpan', function (event, ranges) {
                    $('#legendContainer').find("input").click(function () { setTimeout(plotByChoice, 100); });
                });

                $("#diagramm").bind("plotdblclick", function (event, pos, item) {
                    // zoom out
                    plot = $.plot($(container), datas,
                                  $.extend(true, {}, options, {
                                      xaxis: { min: null, max: null }
                                  }));
                });
                $("#diagramm").dblclick(function () {
                    var axes = $.plot($("#diagramm"), data, options).offset();
                    var axes1 = $.plot($("#diagramm"), data, options).getData();
                    var axes2 = $.plot($("#diagramm"), data, options).getXAxes();
                    var axes3 = $.plot($("#diagramm"), data, options).getYAxes();
                });
                $("#diagramm").bind("plothover", function (event, pos, item) {
                    if (item) {
                        var x = item.datapoint[0].toFixed(2),
                            y = item.datapoint[1].toFixed(2);
                        console.log("x:" + x + ", " + "y:" + y);
                    }
                });
                function plotByChoice()
                {
                        d = [];
                        var i = 0;
                        $('.legendCB').each(
                                function () {

                                    if (this.checked) {
                                        d.push(data[i]);
                                    }
                                    else {
                                        d.push({ label: this.id, data: [] })
                                    }
                                    i++;
                                }
                             );
                        plot = $.plot($("#diagramm"), d, options);
                        $('#legendContainer').find("input").click(function () { setTimeout(plotByChoice, 50); });
                }

                function onDataReceived(series) {
                    
                    $("#loadIcon").hide();
                    isLock = false;
                    //get in session
                    if (series.error) {
                        alert(series.error);
                        return;
                    }
                    data = series.data;
                    for (i = 0; i < data.length; i++) {
                        data[i].label = $("#idEl_" + paramsList[i]).text();
                    }
                    
                    if (hour) {
                        var Min = data[0].data[0];
                        plot = $.plot($("#diagramm"), data, $.extend(true, {}, options, {
                            xaxis: { min: Min[0] }
                        }));
                        $("#zoomOut").css("background-color", "");
                        $("#zoomIn").css("background-color", "rgb(255, 204, 0)");
                    }
                    else {
                        plot = $.plot($("#diagramm"), data, options);
                        $("#zoomOut").css("background-color", "rgb(255, 204, 0)");
                        $("#zoomIn").css("background-color", "");
                    }

                    $('.legendCB').click(function () { plotByChoice(); });
                    
                }

                function onDataError() {
                    $("#loadIcon").hide();
                    
                    plot = $.plot($("#diagramm"), [], options);
                }
                
                function onSend() {
                    isLock = true;
                    var strParam = "";
                    for (i = 0; i < paramsList.length; i++)
                        strParam += (i > 0 ? "|" : "") + db[paramsList[i]].sp + "*" + db[paramsList[i]].param + "*" + db[paramsList[i]].db;
                    var url = "./DiagrammWS.ashx?dt1=" + $("#datepicker1").val() + "&dt2=" + $("#datepicker2").val() + "&params=" + encodeURI(strParam);
                    if (hour)
                        url += "&hour=true";
                    $("#loadIcon").show();
                    $.ajax({
                        url: url,
                        method: 'GET',
                        dataType: 'json',
                        success: onDataReceived,
                        timeout: 30000,
                        error: onDataError
                    });
                }

                function GraphComp() {
                    
                }
                // Увеличить
                $("#zoomIn").click(function () {
                    hour = true;
                    onSend();
                    $(this).css("background-color", "aqua");
                    $("#zoomOut").css("background-color", "aqua");
                })

                // Уменьшить
                $("#zoomOut").click(function () {
                    hour = false;
                    onSend();
                    $("#zoomOut").css("background-color", "aqua");
                    $("#zoomIn").css("background-color", "aqua");
                })
//________________________________________
              
                    
				// Масштабирование
				$("#diagramm").bind("plotselected", function (event, ranges) {
					// clamp the zooming to prevent eternal zoom
					if (ranges.xaxis.to - ranges.xaxis.from < 0.00001)
						ranges.xaxis.to = ranges.xaxis.from + 0.00001;

					if (ranges.yaxis.to - ranges.yaxis.from < 0.00001)
						ranges.yaxis.to = ranges.yaxis.from + 0.00001;
										
					plot = $.plot("#diagramm", graph_data,
						$.extend(true, {}, options, {
							xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
							yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
						})
					);
					
				});
           
                
                function FormatStrNumber(in_val)
                {
                    return in_val < 10 ? '0' + in_val : in_val;
                }

                function onGetData(/*isFirstTime*/) 
                {
                    if (paramsList.length == 0 /*&& !isFirstTime*/) return;
                    if (timeout) clearTimeout(timeout);
                    //if (!isFirstTime)
                        timeout = setTimeout(onSend, isLock ? 5000 : 1000);
                    //else
                    //    timeout = setTimeout(onSend48Hours, isLock ? 5000 : 1000);
                }

                                               
                
                $(".AddLineMenu").menu();
                $(".AddLineMenu").hide();
                $("#lineClearButton").click(function () {
                    paramsList = [];
                    plot = $.plot($("#diagramm"), [], options);
                    $("#legendContainer>table").remove();
                });
              
                $(".AddLineMenu .addLineItem").click(function () {
                   // $(this).hide();
                    var regExp = /idEl_(.+)/.exec(this.id);
                    if (regExp) {
                       
                        paramsList.push(regExp[1]);
                       
                        onGetData();
                    }
                });

                $("#showAddLine").click(function () {
                    $(".AddLineMenu").show();
                    $(document).one("click", function () {
                        $(".AddLineMenu").hide();
                    });
                    return false;
                })
				
				
				$("#SaveParamsBut").click(function() {
					CancelLoad();
					if (paramsList.length == 0) 
					{
						alert("Не выбраны параметры для сохранения");
						return false;
					}
					$(".cmdPanel4").show();
					$("#SaveParamsName").val("");
					return false;
				})
				
				// Сохранение набора параметров
				$("#but_SaveParams").click(function() {
					CancelLoad();
					if (paramsList.length == 0) 
					{
						alert("Не выбраны параметры для сохранения");
						return false;
					}
					
					if ($("#SaveParamsName").val() == "")
					{
						alert("Не указано имя набора параметров для сохранения");
						return false;						
					}

					var strParam = "";
					for (i = 0; i < paramsList.length; i++)
						strParam += (i > 0 ? "|" : "") + db[paramsList[i]].sp + "*" + db[paramsList[i]].param + "*" + db[paramsList[i]].db;

					$("#loadIcon").show();
					$.ajax({
						url: "./SaveParamsWS.ashx?name=" + encodeURI($("#SaveParamsName").val()) + "&params=" + encodeURI(strParam),
						method: 'GET',
						dataType: 'json',
						success: function(recv_data) { 
							$("#loadIcon").hide();
							$(".cmdPanel4").hide();
							$("#SaveParamsName").val("");
							if (recv_data.error)
								alert(recv_data.error);
						},
						timeout: 30000,
						error: function() { 
							$("#loadIcon").hide();
							alert("Не удалось сохранить список параметров");
							$(".cmdPanel4").hide();
							$("#SaveParamsName").val("");
						}
					});
					
				})
				
				// Подготовка построения графиков по сохраненным параметрам
				$("#but_LoadTrend").click(function() {
					var loaded_par_str = $("#SavedParamsList").val();
					var par_array = loaded_par_str.split("|");
					if (par_array.length > 0)
					{
						paramsList = [];
						$.plot($("#diagramm"), [], options);
						for(var i=0; i<par_array.length; i++)
						{
							var one_par_array = par_array[i].split("*");
							if (one_par_array.length >= 3)
							{
								for (j = 0; j < db.length; j++)
								{
									//strParam += (i > 0 ? "|" : "") + db[paramsList[i]].sp + "*" +  + "*" + ;
									if (db[j].param == one_par_array[1] && db[j].db == one_par_array[2])
										paramsList.push(j);
								}
							}
						}
						onSend();
					}
					else
					{
						alert("В этом наборе перечень параметров отсутствует.");
					}
				});
			
                $.plot($("#diagramm"), data, options);

                onGetData();
            });
        </script>

    </div>
        </div>
    <div id="footer">
       

    </div>
    <ul id="AddLineMenu" class="AddLineMenu" runat="server">

        <li>
          
        </li>
    </ul>

    <div id="loadIcon" style="display: none;"><img src="./images/295.gif" /></div>
</asp:Content>
