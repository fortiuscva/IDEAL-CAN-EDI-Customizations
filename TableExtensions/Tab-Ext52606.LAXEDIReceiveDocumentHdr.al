tableextension 52606 "LAX EDI Receive Document Hdr." extends "LAX EDI Receive Document Hdr."
{
    fields
    {
        field(52600; "IDL Vendor PO No."; Code[55])
        {
            Caption = 'Vendor PO No.';
            DataClassification = ToBeClassified;
        }
    }
}
