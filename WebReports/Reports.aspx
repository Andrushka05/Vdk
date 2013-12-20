<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Reports.aspx.cs" Inherits="Reports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="headerTempl" runat="Server">
    <link href="js/jquery-ui-1.10.0.custom.min.css" rel="stylesheet" />
    <link href="js/bootstrap-select.min.css" rel="stylesheet" />
    <link href="js/bootstrap-checkbox.css" rel="stylesheet" />
    <script type="text/javascript" src="js/jquery.event.drag-2.2.js"></script>
    <script type="text/javascript" src="/js/jquery.mousewheel.js"></script>
    <script src="js/bootstrap-select.min.js"></script>
    <script src="js/jquery.timepicker.js"></script>
    <script src="js/jquery.ui.datepicker-ru.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.js"></script>   
    <script type="text/javascript" src="./flot/jquery.flot.crosshair.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.navigate.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.selection.js"></script>
    <script type="text/javascript" src="./flot/jquery.flot.time.js"></script>
    <script type="text/javascript" src="flot/date.js"></script>
    <style type="text/css">
        #reportTable {
            border: black;
            font-family: Times New Roman;
            font-size: 10pt;
            border-collapse: collapse;
            width: 100%;
            background-color: white;
        }
        /* Pills with dropdowns */
        .nav-pills > li > a {
            background: #ECDFDF;
        }

        #navigUl {
            margin-top: 10px;
        }
    </style>
    <script type="text/javascript">
        $(function () {

            GetGroup();
            SetDate();
            $("#datepicker1").datetimepicker({
                dateFormat: "dd.mm.yy",
            });
            $("#datepicker2").datetimepicker({
                dateFormat: "dd.mm.yy",
            });

            $("#group").change(function () {
                var str;
                $("#group option:selected").each(function () {
                    str = $(this).text();
                });
                GetItem(str);
            });

            $("#getData").click(function () {
                GetDataReport();
            });



        });

        function GetDataReport() {
            var str;
            $("#type option:selected").each(function () {
                str = $(this).val();
            });

            var item;
            $("#item option:selected").each(function () {
                item = $(this).val();
            });

            var url = "./Views/JGetReport.ashx?item=" + item + "&dt1=" + $("#datepicker1").val() + "&dt2=" + $("#datepicker2").val() + "&type=" + str.trim();
            $.ajax({
                url: url,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    var res = "<table cellspacing=\"0\" rules=\"all\" border=\"0\" id=\"reportTable\"><tbody><tr>";
                    var d = JSON.parse(data);
                    for (var key in d.Table) {
                        for (var k in d.Table[key]) {
                            res += "<th scope=\"col\">" + k + "</th>";;
                        }
                        break;
                    };
                    res += "</tr>";
                    for (var key in d.Table) {
                        res += "<tr>";
                        //<td align="center">02.12.13 01:00</td>"
                        for (var k in d.Table[key]) {

                            res += "<td align=\"center\">" + d.Table[key][k] + "</td>";
                        }
                        res += "</tr>";
                    };
                    res += "</tbody></table>";
                    $("#report").html(res);
                },
                timeout: 20000,
                error: function (data) { alert(data.error); }
            });
        }

        function GetItem(group) {
            $.ajax({
                url: "./Views/JGetItem.ashx?group=" + group,
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    $("option", $("#item")).remove();
                    var res;
                    data.forEach(function (d) {
                        res += "<option value='" + d.Id + "'>" + d.Name + "</option> ";
                    });
                    $("#item").html(res);
                    var item = $.urlParam('item');
                    if (item) {
                        $("#item option").filter(function () {
                            return $(this).val() == item;
                        }).prop('selected', true);
                    }
                    
                },
                timeout: 10000,
            });
        }

        function GetGroup() {
            $.ajax({
                url: "./Views/JGetGroup.ashx",
                method: 'GET',
                dataType: 'json',
                success: function (data) {
                    $("option", $("#group")).remove();
                    $("option", $("#item")).remove();
                    var res;
                    data.forEach(function (d) {
                        res += "<option value='" + d.Id + "'>" + d.Name + "</option> ";
                    });
                    $("#group").html(res);

                    var gr = $.urlParam('group');
                    if (gr) {
                        $("#group option").filter(function () {
                            return $(this).val() == gr;
                        }).prop('selected', true);
                    }
                    if (gr != "null")
                        GetItem(data[gr - 1].Name);
                    else
                        GetItem(data[0].Name);
                },
                timeout: 10000,
            });
        }

        function SetDate() {
            var dt1 = new Date();
            dt1.setDate(dt1.getDate() - 1);
            var dt1str = FormatStrNumber(dt1.getDate()) + '.' + FormatStrNumber(dt1.getMonth() + 1) + '.' + dt1.getFullYear() + ' ' + FormatStrNumber(dt1.getHours()) + ':00';
            $("#datepicker1").val(dt1str);

            var dt2 = new Date();
            var dt2str = FormatStrNumber(dt2.getDate()) + '.' + FormatStrNumber(dt2.getMonth() + 1) + '.' + dt2.getFullYear() + ' ' + FormatStrNumber(dt2.getHours()) + ':00';
            $("#datepicker2").val(dt2str);
        }

        function FormatStrNumber(in_val) {
            return in_val < 10 ? '0' + in_val : in_val;
        }

        $.urlParam = function (name) {
            return decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) || [, null])[1]);
        }
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="bodyTempl" runat="Server">

    <select id="group" style="width: 100px;" class="selectpicker"></select>

    <select id="item" style="width: 300px;" class="selectpicker"></select>

    <select id="type" style="width: 150px;" class="selectpicker">
        <option value="hour" selected="selected">Часовой отчёт</option>
        <option value="day">Суточный отчёт</option>
    </select>

    <div class="timePanel">
        c:
            <input id="datepicker1" />
        по: 
            <input id="datepicker2" />
    </div>
    <ul class="nav nav-pills" id="navigUl">
        <li class="active"><a id="getData" href="#">Отчёт</a></li>
        <li class="dropdown"><a class="dropdown-toggle" data-toggle="dropdown" href="#">Графики <span class="caret"></span></a>
            <ul class="dropdown-menu">
                <li><a href="#">Обычные</a></li>
                <li class="divider"></li>
                <li class="dropdown-submenu">
          <a href="#">С наложение (7 дней)</a>
          <ul class="dropdown-menu">
            <li><a href="#">Second level link</a></li>
          </ul>
        </li>

            </ul>
        </li>
    </ul>
    <%--<button type="submit" class="btn btn-default" id="getData">Отчёт</button>--%>
    <%--<input id="getData" type="button" value="Отчёт" />--%>
    <div id="report"></div>

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
            
            var graph_data = null; // Данные для построения графиков
            var plot = null; // Объект график
            
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
                        var res = 0;
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
                function plotByChoice() {
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


                function FormatStrNumber(in_val) {
                    return in_val < 10 ? '0' + in_val : in_val;
                }

                function onGetData(/*isFirstTime*/) {
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


                $("#SaveParamsBut").click(function () {
                    CancelLoad();
                    if (paramsList.length == 0) {
                        alert("Не выбраны параметры для сохранения");
                        return false;
                    }
                    $(".cmdPanel4").show();
                    $("#SaveParamsName").val("");
                    return false;
                })

                // Сохранение набора параметров
                $("#but_SaveParams").click(function () {
                    CancelLoad();
                    if (paramsList.length == 0) {
                        alert("Не выбраны параметры для сохранения");
                        return false;
                    }

                    if ($("#SaveParamsName").val() == "") {
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
                        success: function (recv_data) {
                            $("#loadIcon").hide();
                            $(".cmdPanel4").hide();
                            $("#SaveParamsName").val("");
                            if (recv_data.error)
                                alert(recv_data.error);
                        },
                        timeout: 30000,
                        error: function () {
                            $("#loadIcon").hide();
                            alert("Не удалось сохранить список параметров");
                            $(".cmdPanel4").hide();
                            $("#SaveParamsName").val("");
                        }
                    });

                })

                // Подготовка построения графиков по сохраненным параметрам
                $("#but_LoadTrend").click(function () {
                    var loaded_par_str = $("#SavedParamsList").val();
                    var par_array = loaded_par_str.split("|");
                    if (par_array.length > 0) {
                        paramsList = [];
                        $.plot($("#diagramm"), [], options);
                        for (var i = 0; i < par_array.length; i++) {
                            var one_par_array = par_array[i].split("*");
                            if (one_par_array.length >= 3) {
                                for (j = 0; j < db.length; j++) {
                                    //strParam += (i > 0 ? "|" : "") + db[paramsList[i]].sp + "*" +  + "*" + ;
                                    if (db[j].param == one_par_array[1] && db[j].db == one_par_array[2])
                                        paramsList.push(j);
                                }
                            }
                        }
                        onSend();
                    }
                    else {
                        alert("В этом наборе перечень параметров отсутствует.");
                    }
                });

                $.plot($("#diagramm"), data, options);

                onGetData();
            });
        </script>

    </div>
        </div>

</asp:Content>
