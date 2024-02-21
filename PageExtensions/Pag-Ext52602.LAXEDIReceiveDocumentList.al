pageextension 52602 "LAX EDI Receive Document List" extends "LAX EDI Receive Document List"
{
    layout
    {
        addafter("Internal Doc. No.")
        {
            field("IDL Vendor Invoice No."; Rec."Vendor Invoice No.")
            {
                ApplicationArea = all;
            }
            field("IDL Vendor PO No."; Rec."IDL Vendor PO No.")
            {
                ApplicationArea = all;
            }
        }
    }
}
