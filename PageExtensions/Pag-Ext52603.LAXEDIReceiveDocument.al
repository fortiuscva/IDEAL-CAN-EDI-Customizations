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
        EDIFileProcessing: Codeunit "LAX EDI File Processing";
        EDIImport: Codeunit "LAX EDI WS Import";
        EDIDocImport: Codeunit "LAX EDI WS Document Import";
}
