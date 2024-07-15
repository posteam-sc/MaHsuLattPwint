using POS.APP_Data;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Forms;

namespace POS
{
    public partial class StockTransaction : Form
    {
        public StockTransaction()
        {
            InitializeComponent();
        }

        #region Variable
        int _Month_Number;
        List<Product> _nonConProductList;
        List<long> productIdList=new List<long>();
        POSEntities entity = new POSEntities();
        string monthName = "";
        #endregion

        private void StockTransaction_Load(object sender, EventArgs e)
        {
            Localization.Localize_FormControls(this);
            for (int i = 2018; i <= 2030; i++)
            {
                cboYear.Items.Add(i);
            }
            cboYear.SelectedText = DateTime.Now.Year.ToString();
            cboMonth.SelectedText = DateTime.Now.ToString("MMMM");
        }

        private void btnProcess_Click(object sender, EventArgs e)
        {
            //Cursor.Current = Cursors.WaitCursor;
            //_year = Convert.ToInt32(cboYear.Text);
            //Month_Number();

            //productIdList = (from p in entity.Products select p.Id).ToList();

            //if (Utility.Stock_Transaction_Process(_year, _Month_Number, productIdList))
            //{
            //    Cursor.Current = Cursors.Default;
            //    MessageBox.Show("Successfully Process!");
            //}
            //else
            //{
            //    Cursor.Current = Cursors.Default;
            //}

            Cursor.Current = Cursors.WaitCursor;
            productIdList = (from p in entity.Products select p.Id).ToList();
            DateTime dt = Convert.ToDateTime("1-"+cboMonth.Text+"-"+cboYear.Text);

            while (dt < DateTime.Now)
            {
                Utility.Stock_Transaction_Process(dt.Year, dt.Month, productIdList);
                dt = dt.AddMonths(1);
                Application.DoEvents();
            }

            Cursor.Current = Cursors.Default;
            MessageBox.Show("Successfully Process!");
           // Application.Exit();
        }


        private void cboMonth_Number_SelectedIndexChanged(object sender, EventArgs e)
        {
            Month_Number();
        }

        #region Function
        private void Month_Number()
        {
            monthName = cboMonth.Text;
            _Month_Number = DateTime.ParseExact(monthName, "MMMM", System.Globalization.CultureInfo.InvariantCulture).Month;
            //////switch (cboMonth.Text)
            //////{
            //////    case "January":
            //////        _Month_Number = 1;
            //////        break;
            //////    case "February":
            //////        _Month_Number = 2;
            //////        break;
            //////    case "March":
            //////        _Month_Number = 3;
            //////        break;
            //////    case "April":
            //////        _Month_Number = 4;
            //////        break;
            //////    case "May":
            //////        _Month_Number = 5;
            //////        break;
            //////    case "June":
            //////        _Month_Number = 6;
            //////        break;
            //////    case "July":
            //////        _Month_Number = 7;
            //////        break;
            //////    case "August":
            //////        _Month_Number = 8;
            //////        break;
            //////    case "September":
            //////        _Month_Number = 9;
            //////        break;
            //////    case "October":
            //////        _Month_Number = 10;
            //////        break;
            //////    case "November":
            //////        _Month_Number = 11;
            //////        break;
            //////    case "December":
            //////        _Month_Number = 12;
            //////        break;
            //////}
        }

        private void Process()
        {
            _nonConProductList = (from p in entity.Products where p.IsConsignment == false && p.Id == 264241 select p).ToList();
            productIdList = (from n in _nonConProductList select n.Id).Distinct().ToList();
        }
        #endregion


       
    }
}
