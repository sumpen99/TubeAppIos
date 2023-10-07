//
//  FilterSearchMenu.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-20.
//

import SwiftUI

struct FilterSearchMenu:View{
    typealias SearchText = String
    @Binding var iVar:InboxVar
    @FocusState var focusField: Field?
    let onSearch:(SearchCategorie,SearchText) -> Void
    let onReset:() -> Void
    
    let layoutCategories = [
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40))
    ]
    
    var categorieItems:[SearchCategorie] = [
        .MESSAGE,
        .SEGMENT,
        .DIMENSION,
        .STEEL,
        .RADIUS,
        .LENA,
        .LENB,
        .DEGREES
    ]
    
    @ViewBuilder
    var toggleCategoriesButton:some View{
        if iVar.collapseCategories{
            Image(systemName: "chevron.right")
        }
        else{
            Image(systemName: "chevron.down")
        }
        
     }
    
    func getCategorieCell(_ categorie:SearchCategorie) -> some View{
        Toggle(isOn:self.$iVar.searchOption[SearchCategorie.indexOf(op: categorie)]){
            Text(categorie.rawValue).font(.caption).lineLimit(0)
        }
        .onChange(of: self.iVar.searchOption[SearchCategorie.indexOf(op: categorie)]){ value in
            withAnimation{
                if value{
                    iVar.searchCategorie = categorie
                    iVar.setNewSearchIndex(SearchCategorie.indexOf(op: categorie))
                }
                else if iVar.searchCategorie == categorie{
                    iVar.searchCategorie = nil
                }
            }
        }
        .hLeading()
        .toggleStyle(CheckboxStyle(alignLabelLeft: false,labelIsOnColor:.black))
        .padding()
    }
    
    var categoriesGridView:some View{
         LazyVGrid(columns: layoutCategories, spacing: 20.0,pinnedViews: [.sectionHeaders]) {
             ForEach(categorieItems, id: \.self) { categorie in
                 getCategorieCell(categorie)
            }
         }
         .padding()
    }
    
    var categoriesLabel:some View{
        HStack{
            Text("Filter")
            .sectionText(font: .subheadline,color: Color.systemGray)
            Spacer()
            toggleCategoriesButton.foregroundColor(Color.systemBlue)
        }
        .padding([.leading,.trailing,.top])
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation{
                iVar.collapseCategories.toggle()
            }
        }
    }
    
    var categories: some View{
        VStack{
            categoriesLabel
            if !iVar.collapseCategories{
                categoriesGridView
                searchTextField
            }
        }
        .padding(.bottom)
    }
    
    var body:some View{
        ZStack{
            categories
        }
        .background{
            RoundedRectangle(cornerRadius: 10.0).fill(Color.white)
        }
    }
}

extension FilterSearchMenu{
    //MARK: -- SEARCH TEXTFIELD
    var magnifyImage:some View{
        Image(systemName: "magnifyingglass")
        .padding(.leading)
        .padding(.trailing,5.0)
    }
    
    var cancelButton:some View{
        Button("Cancel",action:{
            resetCurrentSearch()
        })
        .padding(.trailing)
        .foregroundColor(Color.systemBlue)
        .hTrailing()
    }
    
    var textField:some View{
        TextField("",text:$iVar.searchText.max(MAX_TEXTFIELD_LEN))
            .preferedSearchField()
            .placeholder("search",
                         when: (focusField != .FIND_STORED_TUBE) && (iVar.searchText.isEmpty))
            .focused($focusField,equals: .FIND_STORED_TUBE)
            .hLeading()
            .onSubmit {
                if iVar.searchText.isEmpty { return }
                if let categorie = iVar.searchCategorie{
                    onSearch(categorie,iVar.searchText)
                }
            }
    }
    
    var searchTextField:some View{
        HStack(spacing:H_SPACING_REG){
            magnifyImage
            textField
            if (focusField == .FIND_STORED_TUBE)||(!iVar.searchText.isEmpty){
                cancelButton
            }
            
        }
        .filledRoundedBackgroundWithBorder(border:.black)
        .foregroundColor(.black)
        .padding([.leading,.trailing])
    }
    
    func resetCurrentSearch(){
        if let categorie = iVar.searchCategorie{
            iVar.searchOption[SearchCategorie.indexOf(op: categorie)] = false
        }
        focusField = nil
        iVar.searchText = ""
        onReset()
    }
}