using System.Web.Http;
using Newtonsoft.Json.Serialization;
using Owin;

namespace Changey
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            var config = new HttpConfiguration();
            config.MapHttpAttributeRoutes();
            config.Formatters.JsonFormatter.SerializerSettings.ContractResolver = new JavaScriptContractResolver();
            app.UseWebApi(config);
        }
    }

    public class JavaScriptContractResolver : CamelCasePropertyNamesContractResolver
    {
        protected override string ResolvePropertyName(string propertyName)
        {
            var name = base.ResolvePropertyName(propertyName);
            return string.Concat(name.Substring(0, 1).ToLowerInvariant(), name.Substring(1));
        }
    }
}