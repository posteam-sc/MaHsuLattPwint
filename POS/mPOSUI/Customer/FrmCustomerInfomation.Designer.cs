namespace POS
{
    partial class FrmCustomerInfomation
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmCustomerInfomation));
            this.reportViewer1 = new Microsoft.Reporting.WinForms.ReportViewer();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.dtpBirthday = new System.Windows.Forms.DateTimePicker();
            this.rdoBirthday = new System.Windows.Forms.RadioButton();
            this.lblSearchTitle = new System.Windows.Forms.Label();
            this.rdoMemberCardNo = new System.Windows.Forms.RadioButton();
            this.rdoCustomerName = new System.Windows.Forms.RadioButton();
            this.btnSearch = new System.Windows.Forms.Button();
            this.txtSearch = new System.Windows.Forms.TextBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.cboMemberType = new System.Windows.Forms.ComboBox();
            this.label10 = new System.Windows.Forms.Label();
            this.groupBox2.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // reportViewer1
            // 
            this.reportViewer1.Font = new System.Drawing.Font("Zawgyi-One", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.reportViewer1.Location = new System.Drawing.Point(5, 26);
            this.reportViewer1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.reportViewer1.Name = "reportViewer1";
            this.reportViewer1.ShowPrintButton = false;
            this.reportViewer1.ShowRefreshButton = false;
            this.reportViewer1.ShowStopButton = false;
            this.reportViewer1.ShowZoomControl = false;
            this.reportViewer1.Size = new System.Drawing.Size(1221, 478);
            this.reportViewer1.TabIndex = 0;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.reportViewer1);
            this.groupBox2.Font = new System.Drawing.Font("Zawgyi-One", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox2.Location = new System.Drawing.Point(7, 162);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.groupBox2.Size = new System.Drawing.Size(1232, 512);
            this.groupBox2.TabIndex = 2;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Customer List";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.dtpBirthday);
            this.groupBox1.Controls.Add(this.rdoBirthday);
            this.groupBox1.Controls.Add(this.lblSearchTitle);
            this.groupBox1.Controls.Add(this.rdoMemberCardNo);
            this.groupBox1.Controls.Add(this.rdoCustomerName);
            this.groupBox1.Controls.Add(this.btnSearch);
            this.groupBox1.Controls.Add(this.txtSearch);
            this.groupBox1.Font = new System.Drawing.Font("Zawgyi-One", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(79)))), ((int)(((byte)(55)))), ((int)(((byte)(46)))));
            this.groupBox1.Location = new System.Drawing.Point(9, 51);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.groupBox1.Size = new System.Drawing.Size(882, 106);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Search By";
            // 
            // dtpBirthday
            // 
            this.dtpBirthday.Location = new System.Drawing.Point(129, 66);
            this.dtpBirthday.Name = "dtpBirthday";
            this.dtpBirthday.Size = new System.Drawing.Size(262, 27);
            this.dtpBirthday.TabIndex = 4;
            // 
            // rdoBirthday
            // 
            this.rdoBirthday.AutoSize = true;
            this.rdoBirthday.Location = new System.Drawing.Point(323, 25);
            this.rdoBirthday.Name = "rdoBirthday";
            this.rdoBirthday.Size = new System.Drawing.Size(71, 24);
            this.rdoBirthday.TabIndex = 2;
            this.rdoBirthday.Text = "Birthday";
            this.rdoBirthday.UseVisualStyleBackColor = true;
            this.rdoBirthday.CheckedChanged += new System.EventHandler(this.rdoBirthday_CheckedChanged);
            // 
            // lblSearchTitle
            // 
            this.lblSearchTitle.AutoSize = true;
            this.lblSearchTitle.Location = new System.Drawing.Point(15, 69);
            this.lblSearchTitle.Name = "lblSearchTitle";
            this.lblSearchTitle.Size = new System.Drawing.Size(104, 20);
            this.lblSearchTitle.TabIndex = 3;
            this.lblSearchTitle.Text = "Member Card No.";
            // 
            // rdoMemberCardNo
            // 
            this.rdoMemberCardNo.AutoSize = true;
            this.rdoMemberCardNo.Checked = true;
            this.rdoMemberCardNo.Location = new System.Drawing.Point(18, 25);
            this.rdoMemberCardNo.Name = "rdoMemberCardNo";
            this.rdoMemberCardNo.Size = new System.Drawing.Size(122, 24);
            this.rdoMemberCardNo.TabIndex = 0;
            this.rdoMemberCardNo.TabStop = true;
            this.rdoMemberCardNo.Text = "Member Card No.";
            this.rdoMemberCardNo.UseVisualStyleBackColor = true;
            this.rdoMemberCardNo.CheckedChanged += new System.EventHandler(this.rdoMemberCardNo_CheckedChanged);
            // 
            // rdoCustomerName
            // 
            this.rdoCustomerName.AutoSize = true;
            this.rdoCustomerName.Location = new System.Drawing.Point(165, 25);
            this.rdoCustomerName.Name = "rdoCustomerName";
            this.rdoCustomerName.Size = new System.Drawing.Size(114, 24);
            this.rdoCustomerName.TabIndex = 1;
            this.rdoCustomerName.Text = "Customer Name";
            this.rdoCustomerName.UseVisualStyleBackColor = true;
            this.rdoCustomerName.CheckedChanged += new System.EventHandler(this.rdoCustomerName_CheckedChanged);
            // 
            // btnSearch
            // 
            this.btnSearch.BackColor = System.Drawing.Color.Transparent;
            this.btnSearch.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(202)))), ((int)(((byte)(125)))));
            this.btnSearch.FlatAppearance.BorderSize = 0;
            this.btnSearch.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnSearch.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnSearch.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSearch.Image = global::POS.Properties.Resources.search_small;
            this.btnSearch.Location = new System.Drawing.Point(413, 55);
            this.btnSearch.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(75, 46);
            this.btnSearch.TabIndex = 5;
            this.btnSearch.UseVisualStyleBackColor = false;
            this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
            // 
            // txtSearch
            // 
            this.txtSearch.Location = new System.Drawing.Point(129, 66);
            this.txtSearch.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtSearch.Name = "txtSearch";
            this.txtSearch.Size = new System.Drawing.Size(262, 27);
            this.txtSearch.TabIndex = 4;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.cboMemberType);
            this.groupBox3.Controls.Add(this.label10);
            this.groupBox3.Font = new System.Drawing.Font("Zawgyi-One", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox3.Location = new System.Drawing.Point(9, 0);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(389, 52);
            this.groupBox3.TabIndex = 0;
            this.groupBox3.TabStop = false;
            // 
            // cboMemberType
            // 
            this.cboMemberType.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cboMemberType.FormattingEnabled = true;
            this.cboMemberType.Location = new System.Drawing.Point(124, 16);
            this.cboMemberType.Name = "cboMemberType";
            this.cboMemberType.Size = new System.Drawing.Size(181, 28);
            this.cboMemberType.TabIndex = 1;
            this.cboMemberType.SelectedIndexChanged += new System.EventHandler(this.cboMemberType_SelectedIndexChanged);
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(10, 19);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(85, 20);
            this.label10.TabIndex = 0;
            this.label10.Text = "Member Type";
            // 
            // FrmCustomerInfomation
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 18F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1251, 676);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.groupBox2);
            this.Font = new System.Drawing.Font("Zawgyi-One", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "FrmCustomerInfomation";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Customer Infomation Report";
            this.Load += new System.EventHandler(this.FrmCustomerInfomation_Load);
            this.groupBox2.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private Microsoft.Reporting.WinForms.ReportViewer reportViewer1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label lblSearchTitle;
        private System.Windows.Forms.RadioButton rdoMemberCardNo;
        private System.Windows.Forms.RadioButton rdoCustomerName;
        private System.Windows.Forms.Button btnSearch;
        private System.Windows.Forms.TextBox txtSearch;
        private System.Windows.Forms.RadioButton rdoBirthday;
        private System.Windows.Forms.DateTimePicker dtpBirthday;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.ComboBox cboMemberType;
        private System.Windows.Forms.Label label10;
    }
}