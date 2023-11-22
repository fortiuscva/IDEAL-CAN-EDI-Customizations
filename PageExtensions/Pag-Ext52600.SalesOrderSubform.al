pageextension 52600 "IDL Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addbefore("LAX EDI Unit Price")
        {
            field("IDL EDI Qty Discr."; Rec."IDL EDI Qty Discr.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the EDI Qty Discr. field.';
                Editable = true;
            }
        }
    }
}
