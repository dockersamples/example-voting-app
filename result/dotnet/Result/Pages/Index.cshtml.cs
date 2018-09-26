using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;

namespace Result.Pages
{
    public class IndexModel : PageModel
    {
        private string _optionA;
        private string _optionB;
        protected readonly IConfiguration _configuration;

        public string OptionA { get; private set; }
        public string OptionB { get; private set; }
        
        public IndexModel(IConfiguration configuration)
        {
            _configuration = configuration;
            _optionA = _configuration.GetValue<string>("Voting:OptionA");
            _optionB = _configuration.GetValue<string>("Voting:OptionB");
        }

        public void OnGet()
        {
            OptionA = _optionA;
            OptionB = _optionB;
        }
    }
}
