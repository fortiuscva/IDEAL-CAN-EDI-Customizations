pageextension 52603 "IDL LAX EDI Receive Document" extends "LAX EDI Receive Document"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field("IDL Vendor PO No."; Rec."IDL Vendor PO No.")
            {
                ApplicationArea = all;
            }
        }
    }
    var
        test: report 14002365;
}
