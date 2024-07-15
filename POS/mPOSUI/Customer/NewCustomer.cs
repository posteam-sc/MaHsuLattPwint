using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using POS.APP_Data;
using System.Text.RegularExpressions;

namespace POS
{
    public partial class NewCustomer : Form
    {
        #region Variables

        public Boolean isEdit { get; set; }

        public int? CustomerId { get; set; }

        private POSEntities entity = new POSEntities();

        private ToolTip tp = new ToolTip();

        public string MemerTypeName { get; set; }

        public string _from { get; set; }

        public char Type { get; set; }

        public string TransactionId;
        #endregion

        public NewCustomer()
        {
            InitializeComponent();
        }

        private void New_Customer_Load(object sender, EventArgs e)
        {
            Localization.Localize_FormControls(this);
            cboTitle.Items.Add("Mr");
            cboTitle.Items.Add("Mrs");
            cboTitle.Items.Add("Miss");
            cboTitle.Items.Add("Ms");
            cboTitle.Items.Add("Daw");
            cboTitle.Items.Add("U");
            cboTitle.SelectedIndex = 0;

            Bind_City();
            if (Type == 'C')
            {
                groupBox1.Enabled = false;
            }
            //else if (Type == 'S')
            //{
            //    groupBox1.BackColor = System.Drawing.Color.Aqua;
            //}
            //else
            //{
            //    groupBox1.BackColor =System.Drawing.Color.Transparent;
            //}

            Bind_MemberType();
            plError.Visible = false;
            Enable_MType(false);
            if (isEdit)
            {
                //Editing here
                Customer currentCustomer = (from c in entity.Customers where c.Id == CustomerId select c).FirstOrDefault<Customer>();
                txtName.Text = currentCustomer.Name;
                txtPhoneNumber.Text = currentCustomer.PhoneNumber;
                txtNRC.Text = currentCustomer.NRC;
                txtAddress.Text = currentCustomer.Address;
                txtEmail.Text = currentCustomer.Email;
                cboTitle.Text = currentCustomer.Title;
                cboCity.Text = currentCustomer.City.CityName;
                if (currentCustomer.Gender == "Male")
                {
                    rdbMale.Checked = true;
                }
                else
                {
                    rdbFemale.Checked = true;
                }

                if (currentCustomer.Birthday == null)
                {
                    dtpBirthday.Value = DateTime.Now.Date;
                }
                else
                {
                    dtpBirthday.Value = currentCustomer.Birthday.Value.Date;
                }

                if (currentCustomer.MemberTypeID != null)
                {
                    cboMemberType.SelectedValue = currentCustomer.MemberTypeID;
                    dtpMemberDate.Value = currentCustomer.StartDate.Value.Date;
                    txtMID.Text = currentCustomer.VIPMemberId;
                    Enable_MType(true);
                }

                ////if (_from == "Sales")
                ////{
                ////    cboMemberType.Text = MemerTypeName;
                ////}
                ////else
                ////{
                ////    cboCity.Text = currentCustomer.MemberType.Name;
                ////}
                btnSubmit.Image = POS.Properties.Resources.update_big;
            }
            else
            {
                int cityId = 0;
                cityId = SettingController.DefaultCity;
                APP_Data.City cus2 = (from c in entity.Cities where c.Id == cityId select c).FirstOrDefault();
                cboCity.Text = cus2.CityName;
                rdbMale.Checked = true;

            }

            if (MemerTypeName != null)
            {
                cboMemberType.Text = MemerTypeName;
                Enable_MType(true);
            }
        }

        public void Bind_City()
        {
            entity = new POSEntities();
            List<APP_Data.City> cityList = new List<APP_Data.City>();
            APP_Data.City city1 = new APP_Data.City();
            city1.Id = 0;
            city1.CityName = "Select";
            cityList.Add(city1);
            cityList.AddRange(entity.Cities.Where(x => x.IsDelete == false).ToList());
            cboCity.DataSource = cityList;
            cboCity.DisplayMember = "CityName";
            cboCity.ValueMember = "Id";
        }

        public void reloadCity(string CityName)
        {
            Bind_City();
            cboCity.Text = CityName;
        }

        public void reloadMemberType(string MType)
        {
            Bind_MemberType();
            cboMemberType.Text = MType;
        }

        public void Bind_MemberType()
        {
            entity = new POSEntities();
            List<APP_Data.MemberType> mTypeList = new List<APP_Data.MemberType>();
            APP_Data.MemberType mType = new APP_Data.MemberType();
            mType.Id = 0;
            mType.Name = "Select";
            mTypeList.Add(mType);
            mTypeList.AddRange(entity.MemberTypes.Where(x => x.IsDelete == false).ToList());
            cboMemberType.DataSource = mTypeList;
            cboMemberType.DisplayMember = "Name";
            cboMemberType.ValueMember = "Id";

            if (mTypeList.Count > 1)
                cboMemberType.SelectedIndex = 0;
        }

        private void btnSubmit_Click(object sender, EventArgs e)
        {
            Boolean hasError = false;

            tp.RemoveAll();
            tp.IsBalloon = true;
            tp.ToolTipIcon = ToolTipIcon.Error;
            tp.ToolTipTitle = "Error";
            //Validation
            if (txtName.Text.Trim() == string.Empty)
            {
                tp.SetToolTip(txtName, "Error");
                tp.Show("Please fill up customer name!", txtName);
                hasError = true;
            }
            //else if (txtPhoneNumber.Text.Trim() == string.Empty && txtEmail.Text.Trim() == string.Empty && txtNRC.Text.Trim() == string.Empty)
            //{
            //    tp.SetToolTip(plError, "Error");
            //    tp.Show("Please fill up one information for these three requirement!", plError);
            //    plError.Visible = true;
            //    hasError = true;
            //}
            else if (cboCity.SelectedIndex == 0)
            {
                tp.SetToolTip(cboCity, "Error");
                tp.Show("Please fill up city name!", cboCity);
                hasError = true;
            }
            else if (txtEmail.Text != string.Empty)
            {
                if (IsEmail(txtEmail.Text) == false)
                {
                    tp.SetToolTip(txtEmail, "Error");
                    tp.Show("Please fill Correct Email Format!", txtEmail);
                    hasError = true;
                }
            }
            else if (cboMemberType.SelectedIndex > 0)
            {
                if (dtpBirthday.Value.Date == System.DateTime.Today.Date)
                {
                    tp.SetToolTip(dtpBirthday, "Error");
                    tp.Show("Please fill up Birthday", dtpBirthday);
                    hasError = true;
                }
                if (txtMID.Text == "")
                {
                    tp.SetToolTip(txtMID, "Error");
                    tp.Show("Please fill up Member Id!", txtMID);
                    hasError = true;
                }
                else
                {

                    int MemberId = 0;
                    if (isEdit == false)
                    {
                        MemberId = (from p in entity.Customers where p.VIPMemberId.Trim() == txtMID.Text.Trim() select p).ToList().Count;

                        if (MemberId > 0)
                        {
                            tp.SetToolTip(txtMID, "Error");
                            tp.Show("This Member Id is already exist!", txtMID);
                            hasError = true;
                        }
                    }
                    else
                    {
                        MemberId = (from p in entity.Customers where p.VIPMemberId.Trim() == txtMID.Text.Trim() && p.Id != CustomerId select p).ToList().Count;

                        if (MemberId > 0)
                        {
                            tp.SetToolTip(txtMID, "Error");
                            tp.Show("This Member Id is already exist!", txtMID);
                            hasError = true;
                        }
                    }
                }
            }
            Customer currentCustomer = new Customer();
            if (!hasError)
            {
                if (isEdit)
                {
                    int CustomerName = 0;
                    CustomerName = (from p in entity.Customers where p.Name.Trim() == txtName.Text.Trim() && p.Id != CustomerId select p).ToList().Count;
                    if (CustomerName == 0)
                    {
                        currentCustomer = (from c in entity.Customers where c.Id == CustomerId select c).FirstOrDefault<Customer>();
                        currentCustomer.Title = cboTitle.Text;
                        currentCustomer.Name = txtName.Text;
                        currentCustomer.PhoneNumber = txtPhoneNumber.Text;
                        currentCustomer.NRC = txtNRC.Text;
                        currentCustomer.Address = txtAddress.Text;
                        currentCustomer.Email = txtEmail.Text;
                        if (rdbMale.Checked == true)
                        {
                            currentCustomer.Gender = "Male";
                        }
                        else
                        {
                            currentCustomer.Gender = "Female";
                        }
                        if (dtpBirthday.Value.Date == DateTime.Now.Date)
                        {
                            currentCustomer.Birthday = null;
                        }
                        else
                        {
                            currentCustomer.Birthday = dtpBirthday.Value.Date;
                        }

                        if (Convert.ToInt32(cboMemberType.SelectedValue) > 0)
                        {
                            currentCustomer.MemberTypeID = Convert.ToInt32(cboMemberType.SelectedValue);
                            currentCustomer.StartDate = dtpMemberDate.Value.Date;
                            currentCustomer.VIPMemberId = txtMID.Text;
                        }
                        else
                        {
                            currentCustomer.MemberTypeID = null;
                            currentCustomer.StartDate = null;
                            currentCustomer.VIPMemberId = null;
                        }

                        currentCustomer.CityId = Convert.ToInt32(cboCity.SelectedValue.ToString());
                        entity.Entry(currentCustomer).State = EntityState.Modified;
                        entity.SaveChanges();

                        MessageBox.Show("Successfully Saved!", "Save");
                        Clear();
                        //  this.Dispose();
                        #region active PaidByCreditWithPrePaidDebt
                        if (System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"] != null)
                        {
                            PaidByCreditWithPrePaidDebt newForm = (PaidByCreditWithPrePaidDebt)System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"];
                            newForm.LoadForm();
                            this.Dispose();
                        }
                        #endregion
                        #region active PaidByCredit
                        if (System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"] != null)
                        {
                            PaidByCreditWithPrePaidDebt newForm = (PaidByCreditWithPrePaidDebt)System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"];
                            newForm.LoadForm();
                            this.Dispose();
                        }
                        #endregion

                        //refresh sales form's customer list
                        if (System.Windows.Forms.Application.OpenForms["CustomerList"] != null)
                        {
                            CustomerList newForm = (CustomerList)System.Windows.Forms.Application.OpenForms["CustomerList"];
                            newForm.DataBind();
                        }
                        if (System.Windows.Forms.Application.OpenForms["Sales"] != null)
                        {
                            Sales newForm = (Sales)System.Windows.Forms.Application.OpenForms["Sales"];

                            newForm.ReloadCustomerList();

                            if (Type != 'S')
                            {
                                newForm.SetCurrentCustomer(currentCustomer.Id);
                            }

                            this.Dispose();
                        }
                    }
                    else if (CustomerName > 0)
                    {
                        tp.SetToolTip(txtName, "Error");
                        tp.Show("This Customer Name is already exist!", txtName);
                    }

                }
                else
                {
                    int CustomerName = 0;
                    CustomerName = (from p in entity.Customers where p.Name.Trim() == txtName.Text.Trim() select p).ToList().Count;
                    if (CustomerName == 0)
                    {
                        var CustomerCode = entity.CustomerAutoID(DateTime.Now, SettingController.DefaultShop.ShortCode);
                        currentCustomer.Title = cboTitle.Text;
                        currentCustomer.Name = txtName.Text;
                        currentCustomer.PhoneNumber = txtPhoneNumber.Text;
                        currentCustomer.NRC = txtNRC.Text;
                        currentCustomer.Email = txtEmail.Text;
                        currentCustomer.Address = txtAddress.Text;
                        currentCustomer.CustomerCode = CustomerCode.FirstOrDefault().ToString();
                        if (rdbMale.Checked == true)
                        {
                            currentCustomer.Gender = "Male";
                        }
                        else
                        {
                            currentCustomer.Gender = "Female";
                        }
                        if (dtpBirthday.Value.Date == DateTime.Now.Date)
                        {
                            currentCustomer.Birthday = null;
                        }
                        else
                        {
                            currentCustomer.Birthday = dtpBirthday.Value.Date;
                        }


                        if (Convert.ToInt32(cboMemberType.SelectedValue) > 0)
                        {
                            currentCustomer.MemberTypeID = Convert.ToInt32(cboMemberType.SelectedValue);
                            currentCustomer.StartDate = dtpMemberDate.Value.Date;
                            currentCustomer.VIPMemberId = txtMID.Text;
                        }

                        currentCustomer.CityId = Convert.ToInt32(cboCity.SelectedValue.ToString());
                        entity.Customers.Add(currentCustomer);
                        entity.SaveChanges();


                        if (TransactionId != null)
                        {
                            var Tran = (from t in entity.Transactions
                                        where t.Id == TransactionId
                                        select t).First();
                            Tran.CustomerId = currentCustomer.Id;
                            entity.SaveChanges();
                        }
                        MessageBox.Show("Successfully Saved!", "Save");
                        //  this.Dispose();
                        Clear();

                        #region active PaidByCreditWithPrePaidDebt
                        if (System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"] != null)
                        {
                            PaidByCreditWithPrePaidDebt newForm = (PaidByCreditWithPrePaidDebt)System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"];
                            newForm.LoadForm();
                            this.Dispose();
                        }
                        #endregion
                        #region active PaidByCredit
                        if (System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"] != null)
                        {
                            PaidByCreditWithPrePaidDebt newForm = (PaidByCreditWithPrePaidDebt)System.Windows.Forms.Application.OpenForms["PaidByCreditWithPrePaidDebt"];
                            newForm.LoadForm();
                            this.Dispose();
                        }
                        #endregion

                        //refresh sales form's customer list
                        if (System.Windows.Forms.Application.OpenForms["CustomerList"] != null)
                        {
                            CustomerList newForm = (CustomerList)System.Windows.Forms.Application.OpenForms["CustomerList"];
                            newForm.DataBind();
                        }

                        if (System.Windows.Forms.Application.OpenForms["Sales"] != null)
                        {
                            Sales newForm = (Sales)System.Windows.Forms.Application.OpenForms["Sales"];
                            if (Type == 'C')
                            {
                                newForm.New = "Yes";
                                newForm.ReloadCustomerList();
                                newForm.SetCurrentCustomer(currentCustomer.Id);
                            }
                            else
                            {
                                newForm.ReloadCustomerList();
                            }


                            this.Dispose();
                        }


                    }
                    else if (CustomerName > 0)
                    {
                        tp.SetToolTip(txtName, "Error");
                        tp.Show("This Customer Name is already exist!", txtName);
                    }
                }

            }
        }

        public void Clear()
        {
            cboTitle.Text = "Mr";
            txtAddress.Text = "";
            txtEmail.Text = "";
            txtName.Text = "";
            txtNRC.Text = "";
            txtPhoneNumber.Text = "";
            dtpBirthday.Value = DateTime.Now.Date;
            rdbMale.Checked = true;
            int cityId = 0;
            cityId = SettingController.DefaultCity;
            APP_Data.City cus2 = (from c in entity.Cities where c.Id == cityId select c).FirstOrDefault();
            cboCity.Text = cus2.CityName;
            btnSubmit.Image = POS.Properties.Resources.save_big;
            isEdit = false;

        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            //DialogResult result = MessageBox.Show("Are you sure you want to cancel?", "Cancel", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
            //if (result.Equals(DialogResult.OK))
            //{
            //    this.Dispose();
            //}
            cboTitle.Text = "Mr";
            txtAddress.Text = "";
            txtEmail.Text = "";
            txtName.Text = "";
            txtNRC.Text = "";
            txtPhoneNumber.Text = "";
            dtpBirthday.Value = DateTime.Now.Date;
            rdbMale.Checked = true;
            int cityId = 0;
            cityId = SettingController.DefaultCity;
            APP_Data.City cus2 = (from c in entity.Cities where c.Id == cityId select c).FirstOrDefault();
            cboCity.Text = cus2.CityName;
            btnSubmit.Image = POS.Properties.Resources.save_big;
        }

        private void New_Customer_MouseMove(object sender, MouseEventArgs e)
        {
            tp.Hide(txtName);
            tp.Hide(txtPhoneNumber);
            tp.Hide(plError);
        }
        public static bool IsEmail(string s)
        {
            Regex EmailExpression = new Regex(@"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$", RegexOptions.Compiled | RegexOptions.Singleline);


            if (!EmailExpression.IsMatch(s))
            {

                return false;

            }

            else
            {

                return true;

            }
        }

        private void btnAddCity_Click(object sender, EventArgs e)
        {
            City newForm = new City();
            newForm.ShowDialog();
        }

        private void cboMemberType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cboMemberType.SelectedValue.ToString() != "0")
            {
                Enable_MType(true);
                // cboMemberType.Enabled = true;
            }
            else
            {
                Enable_MType(false);
                //  cboMemberType.Enabled = false;
            }


        }

        private void Enable_MType(bool b)
        {
            dtpMemberDate.Enabled = b;
            txtMID.Enabled = b;
        }

        private void btnAddMenber_Click(object sender, EventArgs e)
        {
            newMemberType newType = new newMemberType();
            newType.ShowDialog();
        }

        internal void reloadCity(int p)
        {
            throw new NotImplementedException();
        }
    }
}
