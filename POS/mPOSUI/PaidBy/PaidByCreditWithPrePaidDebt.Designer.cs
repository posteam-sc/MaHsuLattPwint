namespace POS
{
    partial class PaidByCreditWithPrePaidDebt
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(PaidByCreditWithPrePaidDebt));
            this.lblPreviousBalance = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.cboCustomerList = new System.Windows.Forms.ComboBox();
            this.lblNetPayableTitle = new System.Windows.Forms.Label();
            this.lblNetPayable = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.lblTotalCost = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.lblAccuralCost = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.chkIsPrePaid = new System.Windows.Forms.CheckBox();
            this.lblPrePaid = new System.Windows.Forms.Label();
            this.txtReceiveAmount = new System.Windows.Forms.TextBox();
            this.Label6 = new System.Windows.Forms.Label();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnAdd = new System.Windows.Forms.Button();
            this.btnSubmit = new System.Windows.Forms.Button();
            this.tableLayoutPanel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblPreviousBalance
            // 
            this.lblPreviousBalance.AutoSize = true;
            this.lblPreviousBalance.Location = new System.Drawing.Point(187, 45);
            this.lblPreviousBalance.Name = "lblPreviousBalance";
            this.lblPreviousBalance.Size = new System.Drawing.Size(16, 18);
            this.lblPreviousBalance.TabIndex = 5;
            this.lblPreviousBalance.Text = "0";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(3, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(118, 18);
            this.label4.TabIndex = 2;
            this.label4.Text = "Customer &Name";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(3, 45);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(123, 18);
            this.label5.TabIndex = 4;
            this.label5.Text = "Previous Balance";
            // 
            // cboCustomerList
            // 
            this.cboCustomerList.FormattingEnabled = true;
            this.cboCustomerList.Location = new System.Drawing.Point(187, 6);
            this.cboCustomerList.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.cboCustomerList.Name = "cboCustomerList";
            this.cboCustomerList.Size = new System.Drawing.Size(109, 26);
            this.cboCustomerList.TabIndex = 3;
            this.cboCustomerList.SelectedIndexChanged += new System.EventHandler(this.cboCustomerList_SelectedIndexChanged);
            // 
            // lblNetPayableTitle
            // 
            this.lblNetPayableTitle.AutoSize = true;
            this.lblNetPayableTitle.Location = new System.Drawing.Point(3, 315);
            this.lblNetPayableTitle.Name = "lblNetPayableTitle";
            this.lblNetPayableTitle.Size = new System.Drawing.Size(87, 18);
            this.lblNetPayableTitle.TabIndex = 14;
            this.lblNetPayableTitle.Text = "Net Payable";
            // 
            // lblNetPayable
            // 
            this.lblNetPayable.AutoSize = true;
            this.lblNetPayable.Location = new System.Drawing.Point(187, 315);
            this.lblNetPayable.Name = "lblNetPayable";
            this.lblNetPayable.Size = new System.Drawing.Size(16, 18);
            this.lblNetPayable.TabIndex = 15;
            this.lblNetPayable.Text = "0";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(3, 270);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(77, 18);
            this.label2.TabIndex = 12;
            this.label2.Text = "Total Cost";
            // 
            // lblTotalCost
            // 
            this.lblTotalCost.AutoSize = true;
            this.lblTotalCost.Location = new System.Drawing.Point(187, 270);
            this.lblTotalCost.Name = "lblTotalCost";
            this.lblTotalCost.Size = new System.Drawing.Size(40, 18);
            this.lblTotalCost.TabIndex = 13;
            this.lblTotalCost.Text = "0000";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 225);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(116, 18);
            this.label1.TabIndex = 0;
            this.label1.Text = "&Receive Amount";
            // 
            // lblAccuralCost
            // 
            this.lblAccuralCost.AutoSize = true;
            this.lblAccuralCost.Location = new System.Drawing.Point(187, 180);
            this.lblAccuralCost.Name = "lblAccuralCost";
            this.lblAccuralCost.Size = new System.Drawing.Size(16, 18);
            this.lblAccuralCost.TabIndex = 11;
            this.lblAccuralCost.Text = "0";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(3, 90);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(115, 18);
            this.label3.TabIndex = 6;
            this.label3.Text = "Prepaid Balance";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(3, 135);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(159, 18);
            this.label7.TabIndex = 8;
            this.label7.Text = "Is Use Prepaid Amount";
            // 
            // chkIsPrePaid
            // 
            this.chkIsPrePaid.AutoSize = true;
            this.chkIsPrePaid.Checked = true;
            this.chkIsPrePaid.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkIsPrePaid.Location = new System.Drawing.Point(187, 139);
            this.chkIsPrePaid.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkIsPrePaid.Name = "chkIsPrePaid";
            this.chkIsPrePaid.Size = new System.Drawing.Size(18, 17);
            this.chkIsPrePaid.TabIndex = 9;
            this.chkIsPrePaid.UseVisualStyleBackColor = true;
            this.chkIsPrePaid.CheckedChanged += new System.EventHandler(this.chkIsPrePaid_CheckedChanged);
            // 
            // lblPrePaid
            // 
            this.lblPrePaid.AutoSize = true;
            this.lblPrePaid.Location = new System.Drawing.Point(187, 90);
            this.lblPrePaid.Name = "lblPrePaid";
            this.lblPrePaid.Size = new System.Drawing.Size(16, 18);
            this.lblPrePaid.TabIndex = 7;
            this.lblPrePaid.Text = "0";
            // 
            // txtReceiveAmount
            // 
            this.txtReceiveAmount.Location = new System.Drawing.Point(187, 231);
            this.txtReceiveAmount.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.txtReceiveAmount.Name = "txtReceiveAmount";
            this.txtReceiveAmount.Size = new System.Drawing.Size(109, 24);
            this.txtReceiveAmount.TabIndex = 1;
            this.txtReceiveAmount.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtReceiveAmount_KeyPress);
            this.txtReceiveAmount.KeyUp += new System.Windows.Forms.KeyEventHandler(this.txtReceiveAmount_KeyUp);
            // 
            // Label6
            // 
            this.Label6.AutoSize = true;
            this.Label6.Location = new System.Drawing.Point(3, 180);
            this.Label6.Name = "Label6";
            this.Label6.Size = new System.Drawing.Size(93, 18);
            this.Label6.TabIndex = 10;
            this.Label6.Text = "Current Cost";
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.BackColor = System.Drawing.Color.Transparent;
            this.tableLayoutPanel1.ColumnCount = 2;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 46.59091F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 53.40909F));
            this.tableLayoutPanel1.Controls.Add(this.lblPreviousBalance, 1, 1);
            this.tableLayoutPanel1.Controls.Add(this.label4, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.label5, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.cboCustomerList, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.lblNetPayableTitle, 0, 7);
            this.tableLayoutPanel1.Controls.Add(this.lblNetPayable, 1, 7);
            this.tableLayoutPanel1.Controls.Add(this.label2, 0, 6);
            this.tableLayoutPanel1.Controls.Add(this.lblTotalCost, 1, 6);
            this.tableLayoutPanel1.Controls.Add(this.label1, 0, 5);
            this.tableLayoutPanel1.Controls.Add(this.Label6, 0, 4);
            this.tableLayoutPanel1.Controls.Add(this.lblAccuralCost, 1, 4);
            this.tableLayoutPanel1.Controls.Add(this.label3, 0, 2);
            this.tableLayoutPanel1.Controls.Add(this.label7, 0, 3);
            this.tableLayoutPanel1.Controls.Add(this.chkIsPrePaid, 1, 3);
            this.tableLayoutPanel1.Controls.Add(this.lblPrePaid, 1, 2);
            this.tableLayoutPanel1.Controls.Add(this.txtReceiveAmount, 1, 5);
            this.tableLayoutPanel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tableLayoutPanel1.ForeColor = System.Drawing.SystemColors.ControlText;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(20, 80);
            this.tableLayoutPanel1.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 8;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.49917F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.49918F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.50328F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.49918F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.49918F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.49918F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.49918F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 12.50167F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(397, 361);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // btnCancel
            // 
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnCancel.FlatAppearance.BorderSize = 0;
            this.btnCancel.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnCancel.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Image = global::POS.Properties.Resources.cancel_big;
            this.btnCancel.Location = new System.Drawing.Point(210, 453);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(146, 50);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.UseVisualStyleBackColor = false;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnAdd
            // 
            this.btnAdd.BackColor = System.Drawing.Color.Transparent;
            this.btnAdd.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnAdd.FlatAppearance.BorderSize = 0;
            this.btnAdd.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnAdd.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnAdd.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAdd.Image = global::POS.Properties.Resources.addnewcustomer;
            this.btnAdd.Location = new System.Drawing.Point(20, 5);
            this.btnAdd.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(241, 63);
            this.btnAdd.TabIndex = 8;
            this.btnAdd.UseVisualStyleBackColor = false;
            this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
            // 
            // btnSubmit
            // 
            this.btnSubmit.BackColor = System.Drawing.Color.Transparent;
            this.btnSubmit.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnSubmit.FlatAppearance.BorderSize = 0;
            this.btnSubmit.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnSubmit.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(223)))), ((int)(((byte)(223)))));
            this.btnSubmit.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSubmit.Image = global::POS.Properties.Resources.save_big;
            this.btnSubmit.Location = new System.Drawing.Point(49, 453);
            this.btnSubmit.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.btnSubmit.Name = "btnSubmit";
            this.btnSubmit.Size = new System.Drawing.Size(142, 50);
            this.btnSubmit.TabIndex = 1;
            this.btnSubmit.UseVisualStyleBackColor = false;
            this.btnSubmit.Click += new System.EventHandler(this.btnSubmit_Click);
            // 
            // PaidByCreditWithPrePaidDebt
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(443, 536);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnAdd);
            this.Controls.Add(this.btnSubmit);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "PaidByCreditWithPrePaidDebt";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "PaidBy Credit";
            this.Load += new System.EventHandler(this.PaidByCreditWithPrePaidDebt_Load);
            this.MouseMove += new System.Windows.Forms.MouseEventHandler(this.PaidByCreditWithPrePaidDebt_MouseMove);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label lblPreviousBalance;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.ComboBox cboCustomerList;
        private System.Windows.Forms.Label lblNetPayableTitle;
        private System.Windows.Forms.Label lblNetPayable;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label lblTotalCost;
        private System.Windows.Forms.Button btnAdd;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblAccuralCost;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.CheckBox chkIsPrePaid;
        private System.Windows.Forms.Label lblPrePaid;
        private System.Windows.Forms.TextBox txtReceiveAmount;
        private System.Windows.Forms.Button btnSubmit;
        private System.Windows.Forms.Label Label6;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    }
}