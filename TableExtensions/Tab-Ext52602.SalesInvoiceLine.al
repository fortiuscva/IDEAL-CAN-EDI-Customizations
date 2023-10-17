tableextension 52602 "IDL Sales Invoice Line" extends "Sales Invoice Line"
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
