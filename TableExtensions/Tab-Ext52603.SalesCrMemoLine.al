tableextension 52603 "IDL Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(52600; "IDL EDI Qty Discr."; Boolean)
        {
            Caption = 'EDI Qty Discr.';
            DataClassification = ToBeClassified;
        }
    }
}
