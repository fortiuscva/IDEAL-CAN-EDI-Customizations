pageextension 52601 "IDL LAX EDI Send Document" extends "LAX EDI Send Document"
{
    actions
    {
        addlast("F&unctions")
        {
            action("IDL UpdateDocument")
            {
                ApplicationArea = All;
                Caption = 'Update Document';
                Promoted = true;
                PromotedIsBig = true;
                Image = UpdateShipment;

                trigger OnAction()
                var
                    EDISendDocumentRecLcl: Record "LAX EDI Send Document Hdr.";
                    IDLUpdateSendDocument: Report "IDL Update - Send Document";
                begin
                    EDISendDocumentRecLcl.Reset();
                    EDISendDocumentRecLcl.SetRange("No.", Rec."No.");
                    EDISendDocumentRecLcl.FindFirst();
                    Clear(IDLUpdateSendDocument);
                    IDLUpdateSendDocument.SetValues(EDISendDocumentRecLcl);
                    IDLUpdateSendDocument.SetTableView(EDISendDocumentRecLcl);
                    IDLUpdateSendDocument.UseRequestPage := true;
                    IDLUpdateSendDocument.RunModal();
                end;
            }
        }
    }
}
