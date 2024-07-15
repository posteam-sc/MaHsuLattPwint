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

namespace POS
{
    public partial class CustomerDetail : Form
    {
        #region Variables

        POSEntities entity = new POSEntities();
        public int customerId;
        public long TotalOutstanding;
        public long PayableAmt;
        int RefundAmount = 0;
        public string note = "";
        private string transactionparentId = string.Empty;
        #endregion

        public CustomerDetail()
        {
            InitializeComponent();
        }

        private void CustomerDetail_Load(object sender, EventArgs e)
        {
            Localization.Localize_FormControls(this);
            LoadData();
        }

        public void LoadData()
        {
            Customer cust = (from c in entity.Customers where c.Id == customerId select c).FirstOrDefault<Customer>();

            lblName.Text = cust.Title + " " + cust.Name;
            lblPhoneNumber.Text = cust.PhoneNumber;
            lblNrc.Text = cust.NRC;
            lblAddress.Text = cust.Address;
            lblEmail.Text = cust.Email;
            lblGender.Text = cust.Gender;
            lblBirthday.Text = cust.Birthday != null ? Convert.ToDateTime(cust.Birthday).ToString("dd-MM-yyyy") : "-";
            lblCity.Text = cust.City != null ? cust.City.CityName : "-";
            dgvOldTransaction.AutoGenerateColumns = false;
            dgvOutstandingTransaction.AutoGenerateColumns = false;
            dgvPrePaid.AutoGenerateColumns = false;
            List<Transaction> transList = cust.Transactions.Where(trans => trans.IsPaid == false && (trans.IsDeleted == null || trans.IsDeleted == false)).Where(trans => trans.Type != TransactionType.Prepaid
                                                     ).ToList();
            List<Transaction> DataBindTransList = new List<Transaction>();
            foreach (Transaction ts in transList)
            {
                List<Transaction> rtList = new List<Transaction>();
                rtList = (from t in entity.Transactions where t.Type == TransactionType.CreditRefund && t.ParentId == ts.Id select t).ToList().Where(x => x.IsDeleted != true).ToList();
                RefundAmount = 0;
                if (rtList.Count > 0)
                {
                    foreach (Transaction rt in rtList)
                    {
                        RefundAmount += (int)rt.RecieveAmount;
                    }
                }
                if (RefundAmount > 0)
                {
                    if (RefundAmount != ts.TotalAmount)
                    {
                        DataBindTransList.Add(ts);
                    }
                }
                else if (RefundAmount == 0)
                {
                    DataBindTransList.Add(ts);
                }
            }

            dgvOutstandingTransaction.DataSource = DataBindTransList;

            int TotalRefund = 0, TotalOutstanding = 0;
            foreach (DataGridViewRow row in dgvOutstandingTransaction.Rows)
            {
                TotalOutstanding += Convert.ToInt32(row.Cells[4].Value);
                TotalRefund += Convert.ToInt32(row.Cells[5].Value);
            }
            lblTotalOutstanding.Text = TotalOutstanding.ToString();

            dgvOldTransaction.DataSource = cust.Transactions.Where(trans => trans.IsPaid == true && (trans.IsDeleted == null || trans.IsDeleted == false)).ToList();
            //dgvPrePaid.DataSource = cust.Transactions.Where(tras => tras.Type == TransactionType.Prepaid).Where(trans => trans.IsActive == false).ToList();
            var PrepaidList = cust.Transactions.Where(tras => tras.Type == TransactionType.Prepaid).Where(trans => trans.IsActive == false).ToList();

            lblPayableAmt.Text = (TotalOutstanding - PrepaidList.AsEnumerable().Sum(s => s.TotalAmount)).ToString();
            dgvPrePaid.DataSource = PrepaidList;
        }

        public void Reload()
        {
            entity = new POSEntities();
            Customer cust = (from c in entity.Customers where c.Id == customerId select c).FirstOrDefault<Customer>();
            List<Transaction> transList = cust.Transactions.Where(trans => trans.IsPaid == false && (trans.IsDeleted == null || trans.IsDeleted == false)).Where(trans => trans.Type != TransactionType.Prepaid).ToList();
            List<Transaction> DataBindTransList = new List<Transaction>();
            foreach (Transaction ts in transList)
            {
                List<Transaction> rtList = new List<Transaction>();
                rtList = (from t in entity.Transactions where t.Type == TransactionType.CreditRefund && t.ParentId == ts.Id select t).ToList().Where(x => x.IsDeleted != true).ToList();
                RefundAmount = 0;
                if (rtList.Count > 0)
                {
                    foreach (Transaction rt in rtList)
                    {
                        RefundAmount += (int)rt.RecieveAmount;
                    }
                }
                if (RefundAmount > 0)
                {
                    if (RefundAmount != ts.TotalAmount)
                    {
                        DataBindTransList.Add(ts);
                    }
                }
                else if (RefundAmount == 0)
                {
                    DataBindTransList.Add(ts);
                }
            }

            dgvOutstandingTransaction.DataSource = DataBindTransList;



            dgvOldTransaction.DataSource = cust.Transactions.Where(trans => trans.IsPaid == true && (trans.IsDeleted == null || trans.IsDeleted == false)).ToList();

            dgvPrePaid.DataSource = cust.Transactions.Where(tras => tras.Type == TransactionType.Prepaid).Where(trans => trans.IsActive == false).ToList();


            //Need to recheck

            TotalOutstanding = 0;
            foreach (DataGridViewRow row in dgvOutstandingTransaction.Rows)
            {
                TotalOutstanding += Convert.ToInt32(row.Cells[4].Value);
            }
            PayableAmt = 0;
            foreach (DataGridViewRow row in dgvPrePaid.Rows)
            {
                PayableAmt += Convert.ToInt32(row.Cells[4].Value);
            }

            lblTotalOutstanding.Text = TotalOutstanding.ToString();
            lblPayableAmt.Text = (TotalOutstanding - PayableAmt).ToString();

        }

        private void dgvOldTransaction_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            foreach (DataGridViewRow row in dgvOldTransaction.Rows)
            {
                Transaction ts = (Transaction)row.DataBoundItem;
                row.Cells[0].Value = ts.Id;
                row.Cells[1].Value = ts.DateTime.Value.ToString("dd-MM-yyyy");
                row.Cells[2].Value = ts.DateTime.Value.ToString("hh:mm");
                row.Cells[3].Value = ts.User.Name;
                row.Cells[4].Value = ts.Type;
                row.Cells[5].Value = ts.TotalAmount;
                if (ts.Type != TransactionType.CreditRefund && ts.Type != TransactionType.Refund)
                {
                    row.Cells[6].Value = ts.RecieveAmount;
                    row.Cells[7].Value = 0;
                }
                else
                {
                    row.Cells[6].Value = 0;
                    row.Cells[7].Value = ts.RecieveAmount;
                }

                //List<Transaction> OldOutStandingList = entity.Transactions.Where(x => x.CustomerId == ts.CustomerId).Where(x => x.IsPaid == false).Where(x => x.DateTime < ts.DateTime).ToList();

                //long OldOutstandingAmount = 0;

                //foreach (Transaction t in OldOutStandingList)
                //{
                //    OldOutstandingAmount += (long)t.TotalAmount - (long)t.RecieveAmount;
                //}

                //row.Cells[4].Value = (ts.TotalAmount + OldOutstandingAmount) - ts.RecieveAmount;
            }
        }

        private void dgvOutstandingTransaction_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            foreach (DataGridViewRow row in dgvOutstandingTransaction.Rows)
            {
                Transaction ts = (Transaction)row.DataBoundItem;
                row.Cells[0].Value = ts.Id;
                row.Cells[1].Value = ts.DateTime.Value.ToString("dd-MM-yyyy");
                row.Cells[2].Value = ts.DateTime.Value.ToString("hh:mm");
                row.Cells[3].Value = ts.User.Name;
                long itemDiscount = (long)ts.TransactionDetails.Sum(x => (x.UnitPrice * (x.DiscountRate / 100)) * x.Qty).Value;
                long totalDiscount = (long)ts.DiscountAmount - itemDiscount;
                long UsedPrepaid = ts.UsePrePaidDebts.Sum(x => x.UseAmount).Value;
                List<Transaction> rtList = new List<Transaction>();

                rtList = (from t in entity.Transactions where t.Type == TransactionType.CreditRefund && t.ParentId == ts.Id && t.IsDeleted != true select t).ToList();
                RefundAmount = 0;
                if (rtList.Count > 0)
                {
                    foreach (Transaction rt in rtList)
                    {
                        RefundAmount += (int)rt.RecieveAmount;
                    }
                }
                //List<Transaction> OldOutStandingList = entity.Transactions.Where(x => x.CustomerId == ts.CustomerId).Where(x => x.IsPaid == false).Where(x => x.DateTime < ts.DateTime ).ToList().Where(x => x.IsDeleted != true).ToList();

                //long OldOutstandingAmount = 0;

                //foreach (Transaction t in OldOutStandingList)
                //{
                //    OldOutstandingAmount += (long)t.TotalAmount - (long)t.RecieveAmount - (long)t.DiscountAmount;
                //}

                row.Cells[4].Value = ((ts.TotalAmount) - ts.RecieveAmount) - RefundAmount - UsedPrepaid;
                row.Cells[5].Value = RefundAmount;
            }
        }

        private void dgvPrePaid_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            foreach (DataGridViewRow row in dgvPrePaid.Rows)
            {
                Transaction prepaidTransObj = (Transaction)row.DataBoundItem;
                row.Cells[0].Value = prepaidTransObj.Id;
                row.Cells[1].Value = prepaidTransObj.DateTime.Value.ToString("dd-MM-yyyy");
                row.Cells[2].Value = prepaidTransObj.DateTime.Value.ToString("hh:mm");
                row.Cells[3].Value = prepaidTransObj.Type;
                int useAmount = (prepaidTransObj.UsePrePaidDebts1 == null) ? 0 : (int)prepaidTransObj.UsePrePaidDebts1.Sum(x => x.UseAmount);
                row.Cells[4].Value = prepaidTransObj.RecieveAmount - useAmount;
                row.Cells[5].Value = true;
            }
        }

        private void dgvOutstandingTransaction_CellClick(object sender, DataGridViewCellEventArgs e)
        {


            if (e.RowIndex >= 0)
            {

                string transactionId = dgvOutstandingTransaction.Rows[e.RowIndex].Cells[0].Value.ToString();
                //Paid
                DataGridViewRow row = dgvOutstandingTransaction.Rows[e.RowIndex];

                //View Detail
                if (e.ColumnIndex == 8)
                {
                    //Transaction Detail
                    TransactionDetailForm form = new TransactionDetailForm();
                    form.transactionId = dgvOutstandingTransaction.Rows[e.RowIndex].Cells[0].Value.ToString();
                    form.Show();
                }
                //View Refund Detail
                else if (e.ColumnIndex == 7)
                {
                    //RefundDetail form = new RefundDetail();
                    //form.transactionId = dgvOutstandingTransaction.Rows[e.RowIndex].Cells[0].Value.ToString();
                    //form.IsRefund = true;
                    //form.Show();
                    RefundList form = new RefundList();
                    form.transactionId = dgvOutstandingTransaction.Rows[e.RowIndex].Cells[0].Value.ToString();
                    form.Show();


                }
            }
        }

        private void dgvOldTransaction_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                DataGridViewRow row = dgvOldTransaction.Rows[e.RowIndex];
                if (e.ColumnIndex == 8)
                {
                    Transaction ResultTrans = (Transaction)row.DataBoundItem;
                    if (ResultTrans.Type != TransactionType.CreditRefund)
                    {
                        TransactionDetailForm form = new TransactionDetailForm();
                        form.transactionId = dgvOldTransaction.Rows[e.RowIndex].Cells[0].Value.ToString();
                        form.ShowDialog();
                    }
                    else
                    {
                        RefundDetail form = new RefundDetail();
                        form.transactionId = row.Cells[0].Value.ToString();
                        form.IsRefund = false;
                        form.ShowDialog();
                    }
                }
            }
        }

        private void btnPaidTransaction_Click(object sender, EventArgs e)
        {
            List<Transaction> tList = new List<Transaction>();
            List<Transaction> PrePaidDebtList = new List<Transaction>();
            // Boolean IsError = false;
            //long totalPaidAmount = 0; long totalPrePaidAmount = 0;         
            if (dgvOutstandingTransaction.Rows.Count >= 0)
            {
                foreach (DataGridViewRow row in dgvOutstandingTransaction.Rows)
                {
                    if (Convert.ToBoolean(row.Cells[6].Value))
                    {
                        Transaction tObj = (Transaction)row.DataBoundItem;
                        tList.Add(tObj);
                    }

                    transactionparentId = Convert.ToString(row.Cells[0].Value);
                }
                foreach (DataGridViewRow row in dgvPrePaid.Rows)
                {
                    if (Convert.ToBoolean((bool)row.Cells[5].Value))
                    {
                        Transaction tObj = (Transaction)row.DataBoundItem;
                        PrePaidDebtList.Add(tObj);
                    }


                }

                if (tList.Count == 0)
                {
                    MessageBox.Show("Please select transactions that you want to paid");
                    return;
                }


                frmPaidByCredit form = new frmPaidByCredit();
                form.isDebt = true;
                form.Note = note;
                form.transactionParentId = transactionparentId;
                form.CustomerId = customerId;
                form.CreditTransaction = tList;
                form.PrePaidTransaction = PrePaidDebtList;
                form.Show();
            }
            else
            {
                MessageBox.Show("There is no credit transaction to pay!");
            }
        }

        private void btnPaidCash_Click(object sender, EventArgs e)
        {
            List<Transaction> tList = new List<Transaction>();
            List<Transaction> PrePaidDebtList = new List<Transaction>();

            foreach (DataGridViewRow row in dgvOutstandingTransaction.Rows)
            {
                Transaction tObj = (Transaction)row.DataBoundItem;
                tList.Add(tObj);
                transactionparentId = Convert.ToString(row.Cells[0].Value);
            }
            foreach (DataGridViewRow row in dgvPrePaid.Rows)
            {
                Transaction tObj = (Transaction)row.DataBoundItem;
                PrePaidDebtList.Add(tObj);
            }

            if (tList.Count > 0)
            {
                frmPaidByCredit form = new frmPaidByCredit();
                form.isDebt = true;
                form.Note = note;
                form.transactionParentId = transactionparentId;
                form.CustomerId = customerId;
                form.CreditTransaction = tList;
                form.PrePaidTransaction = PrePaidDebtList;
                form.Show();
            }
            else
            {
                MessageBox.Show("There is no credit transaction to pay!");
            }
        }

        private void btnnote_Click(object sender, EventArgs e)
        {
            if (note == "")
            {
                AddNote form = new AddNote();
                form.status = "ADD";

                form.ShowDialog();
            }
            else
            {
                AddNote form = new AddNote();
                form.status = "EDIT";
                form.editnote = note;
                form.ShowDialog();
            }
        }

        private void dgvPrePaid_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                DataGridViewRow row = dgvOldTransaction.Rows[e.RowIndex];
                if (e.ColumnIndex == 5)
                {
                    string v = e.ColumnIndex.ToString();
                }
            }

        }



    }
}
