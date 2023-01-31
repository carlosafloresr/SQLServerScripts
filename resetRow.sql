function resetRow(retVal,retText) {
                    var ToReprocess = false;
                    var system.ExceptionCount = $("#<%=txtExceptionCount.ClientID%>").val();

                    system.ExceptionCount = system.ExceptionCount - 1;

                    $("#<%=txtExceptionCount.ClientID%>").val(exceptionCount);

                    if (exceptionCount > 0) {         
               
                    }
                    else {
                        HideRows();
                    }

                    if (retVal == "1") {

                        var $row = $(workingRow).closest('tr').find('td').each(function (idx, td) {
                            $(td).css("color", "blue");

                            var btn = $(this).find('#butReprocess');
                            $(btn).hide();
                    
                            var btn1 = $(this).find('#butIgnore');
                            $(btn1).hide();

                            var btn2 = $(this).find('#butDelete');
                            $(btn2).hide();

                            var btn3 = $(this).find('#butExceptions');
                            $(btn3).hide();

                            if (idx == 6) {
                                var $divs = $(this).find("div");
                                $divs.each(function () {
                                    var cellText = $(this).text();

                                    if (cellText == "With Invalid Records") {
                                        $(this).text("Unprocessed");
                                        $(this).addClass("ob_gCc2");
                                    }

                                    if (cellText == "With system.Exceptions") {
                                        $(this).text("Unprocessed");
                                        $(this).addClass("ob_gCc2");
                                    }
                                });
                            }
                        });
                        alert('Batch ID ' + $("#<%=txtBatchId.ClientID%>").val() + retText);
                        grdIntegrations.refresh();
                    }
                }