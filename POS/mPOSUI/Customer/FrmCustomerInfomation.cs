using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;
using POS.APP_Data;

namespace POS
{
    public partial class FrmCustomerInfomation : Form
    {
        
        public FrmCustomerInfomation()
        {
            InitializeComponent();
        }
        APP_Data.POSEntities entity = new APP_Data.POSEntities();
       List<APP_Data.Customer> customerList = new List<APP_Data.Customer>();
      

        private void FrmCustomerInfomation_Load(object sender, EventArgs e)
        {
            Localization.Localize_FormControls(this);
            Bind_MemberType();
            VisbleByRadio();
            LoadData();
        }

        //private void loadData()
        //{
        //    cusList.Clear();
        //    cusList = entity.Customers.ToList();
        //    ShowReportViewer();
        //}

        private void LoadData()
        {
           customerList.Clear();

           

            if (cboMemberType.SelectedIndex == 0)
            {
                customerList = entity.Customers.ToList();
                
            }
            else
            {
                customerList = (from c in entity.Customers.AsEnumerable() where c.MemberTypeID == Convert.ToInt32(cboMemberType.SelectedValue) select c).ToList();
               // _reportCustomerList = (from c in customerList.AsEnumerable() where c.MemberTypeID == Convert.ToInt32(cboMemberType.SelectedValue) select c).ToList();
            }

            if (txtSearch.Visible == true)
            {
                if (txtSearch.Text.Trim() != string.Empty)
                {
                    if (rdoMemberCardNo.Checked)
                    {
                        //Search BY Member Card No
                       customerList = customerList.Where(x => x.VIPMemberId == txtSearch.Text.Trim()).ToList();
                      //  _reportCustomerList = customerList.Where(x => x.VIPMemberId == txtSearch.Text.Trim()).ToList();
                    }
                    else if (rdoCustomerName.Checked)
                    {
                        //Search BY Customer Name 
                      // _reportCustomerList= customerList.Where(x => x.Name.Trim().ToLower().Contains(txtSearch.Text.Trim().ToLower())).ToList();
                        customerList = customerList.Where(x => x.Name.Trim().ToLower().Contains(txtSearch.Text.Trim().ToLower())).ToList();
                    }
                }
            }
            else
            {
                if (rdoBirthday.Checked)
                {
                    DateTime fromDate = dtpBirthday.Value.Date;

                    var filterCustomer = (from c in customerList where c.Birthday != null select c).ToList();
                    customerList = (from f in filterCustomer where f.Birthday.Value.Date == fromDate select f).ToList<Customer>();
                   // _reportCustomerList= (from f in filterCustomer where f.Birthday.Value.Date == fromDate select f).ToList<Customer>();
                }
            }
            ShowReportViewer();
        }

        private void ShowReportViewer()
        {

            dsReportTemp dsReport = new dsReportTemp();
            dsReportTemp.CustomerInformationDataTable dtCustomerReport = (dsReportTemp.CustomerInformationDataTable)dsReport.Tables["CustomerInformation"];
            foreach (Customer c in customerList)
            {
                dsReportTemp.CustomerInformationRow newRow = dtCustomerReport.NewCustomerInformationRow();
                newRow.Name = c.Name + "," + c.Title;
                newRow.Birthday = (c.Birthday == null) ? "" : c.Birthday.Value.Date.ToString("dd/MM/yyyy");
                newRow.Gender = (c.Gender == "") ? "" : c.Gender;
                newRow.NRC = (c.NRC == null || c.NRC == "") ? "" : c.NRC;
                newRow.PhNo = (c.PhoneNumber == "" || c.PhoneNumber == "") ? "" : c.PhoneNumber;
                newRow.Email = (c.Email == null || c.Email == "") ? "" : c.Email;
                newRow.Address = (c.Address == null || c.Address == "") ? "" : c.Address;
                newRow.TownShip = (c.TownShip == null || c.TownShip == "") ? "" : c.TownShip;
                newRow.City = (c.City.CityName == null || c.City.CityName == "") ? "" : c.City.CityName;
                newRow.VIPMemberId = (c.VIPMemberId == null || c.VIPMemberId == "") ? "" : c.VIPMemberId;//recheck

                dtCustomerReport.AddCustomerInformationRow(newRow);
            }

            ReportDataSource rds = new ReportDataSource("DataSet1", dsReport.Tables["CustomerInformation"]);
           // ReportDataSource rds = new ReportDataSource("DataSet1", _reportCustomerList);
            string reportPath = string.Empty;
            reportPath = Application.StartupPath + "\\Reports\\AllMemberInformation.rdlc";

            reportViewer1.LocalReport.ReportPath = reportPath;
            reportViewer1.LocalReport.DataSources.Clear();
            reportViewer1.LocalReport.DataSources.Add(rds);
            reportViewer1.RefreshReport();
        }

        #region Method
        private void Bind_MemberType()
        {
            List<APP_Data.MemberType> mTypeList = new List<APP_Data.MemberType>();
            APP_Data.MemberType mType = new APP_Data.MemberType();
            mType.Id = 0;
            mType.Name = "All";
            mTypeList.Add(mType);
            mTypeList.AddRange(entity.MemberTypes.ToList());
            cboMemberType.DataSource = mTypeList;
            cboMemberType.DisplayMember = "Name";
            cboMemberType.ValueMember = "Id";
        }
        #endregion

        private void btnSearch_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        private void rdoMemberCardNo_CheckedChanged(object sender, EventArgs e)
        {
            lblSearchTitle.Text = "Member Card No.";
            VisibleControl(true, false);
        }

        private void rdoCustomerName_CheckedChanged(object sender, EventArgs e)
        {
            lblSearchTitle.Text = "Customer Name";
            VisibleControl(true, false);
        }

        private void VisibleControl(bool t, bool f)
        {
            txtSearch.Visible = t;
            dtpBirthday.Visible = f;
        }

        private void VisbleByRadio()
        {
            if (rdoMemberCardNo.Checked == true || rdoCustomerName.Checked == true)
            {
                VisibleControl(true, false);
            }
            else
            {
                VisibleControl(false, true);
            }
        }

        private void rdoBirthday_CheckedChanged(object sender, EventArgs e)
        {
            lblSearchTitle.Text = "Birthday";
            VisibleControl(false, true);
        }

        private void cboMemberType_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadData();
        }

    }
}
