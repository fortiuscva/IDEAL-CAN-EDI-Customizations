report 52600 "IDL Update - Send Document"
{
    Caption = 'Update - Send Document';
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = true;
    ProcessingOnly = true;

    dataset
    {
        dataitem(LAXEDISendDocumentHdr; "LAX EDI Send Document Hdr.")
        {
            DataItemTableView = sorting("No.");
            trigger OnAfterGetRecord()
            begin
                Validate("Funct. Group Ack. Status", LAXEDIGroupAckStatusVarGbl);
            Validate("Tran. Set Funct. Ack. Status", LAXEDITranSetAckStatusVarGbl);
            Modify();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(LAXEDIGroupAckStatusVarGbl; LAXEDIGroupAckStatusVarGbl)
                    {
                        Caption = 'Funct. Group Ack. Status';
                        ApplicationArea = All;
                    }
                    field(LAXEDITranSetAckStatusVarGbl; LAXEDITranSetAckStatusVarGbl)
                    {
                        Caption = 'Tran. Set Funct. Ack. Status';
                        ApplicationArea = All;
                    }

                }


            }
        }

        trigger OnOpenPage()
        begin
            LAXEDIGroupAckStatusVarGbl := LAXEDISendDocumentRecGbl."Funct. Group Ack. Status";
            LAXEDITranSetAckStatusVarGbl := LAXEDISendDocumentRecGbl."Tran. Set Funct. Ack. Status";
        end;
    }

    procedure SetValues(Var LAXEDISendDocumentPar: Record "LAX EDI Send Document Hdr.")
    begin
        LAXEDISendDocumentRecGbl := LAXEDISendDocumentPar;
    end;

    var
        LAXEDIGroupAckStatusVarGbl: Enum "LAX EDI Group Ack. Status";
                                        LAXEDITranSetAckStatusVarGbl: Enum "LAX EDI Tran. Set Ack. Status";
                                        LAXEDISendDocumentRecGbl: Record "LAX EDI Send Document Hdr.";

}