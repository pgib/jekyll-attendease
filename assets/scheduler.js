var AttendeaseSchedulerHelper = {
  microsoft: false,

  addEvent: function(obj, eventType, targetFunction, useCapture)
  {
    if (obj.addEventListener)
    {
      obj.addEventListener(eventType, targetFunction, false);
    }
    else if (obj.attachEvent)
    {
      obj.attachEvent('on' + eventType, targetFunction);
    }
    else
    {
      obj['on' + eventType] = targetFunction;
    }
  },

  onScheduleStatusCheck: function(callback)
  {
    if (document.createEvent)
    {
      this.addEvent(document, "attendease.gotsessionstatus", callback);
    }
    else if (document.attachEvent)
    {
      this.addEvent(document, "dataavailable", callback);
    }
  },

  sessionStatus: function()
  {
    var xmlhttp = false;

    if (window.XMLHttpRequest)
    {
      xmlhttp = new XMLHttpRequest();
    }
    else if (window.ActiveXObject)
    {
      try
      {
        xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
      }
      catch (e)
      {
        try
        {
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        catch (e)
        {
          xmlhttp = false;
        }
      }
    }

    if (xmlhttp)
    {
      xmlhttp.onreadystatechange = function()
      {
        if (xmlhttp.readyState == 4)
        {
          var statusObject = false;

          if (xmlhttp.status == 200)
          {
            statusObject = JSON.parse(xmlhttp.responseText);

            for (instanceId in statusObject)
            {
              // TODO: Don't use JQuery?
              $("[data-instance-id=" + instanceId + "]").find('.attendease-schedule-status').html(statusObject[instanceId])
            }
          }

          data = { status: statusObject };

          if (document.createEvent)
          {
            e = document.createEvent("HTMLEvents");
            e.initEvent("attendease.gotsessionstatus", true, true);
            e.data = data;
            document.dispatchEvent(e);
          }
          else if (document.attachEvent)
          {
            e = document.createEventObject();
            e.eventType = "attendease.gotsessionstatus";
            e.memo = data;
            document.fireEvent("ondataavailable", e);
          }
        }
      }
      xmlhttp.open("GET","/api/schedule_status.json",true);
      xmlhttp.send();
    }
  }
};

if (window.ActiveXObject)
{
  AttendeaseSchedulerHelper.addEvent(window, 'load', AttendeaseSchedulerHelper.sessionStatus);
}
else
{
  AttendeaseSchedulerHelper.addEvent(document, 'DOMContentLoaded', AttendeaseSchedulerHelper.sessionStatus);
}
