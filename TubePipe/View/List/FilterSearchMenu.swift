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
            Text(categorie.rawValue).font(.body).lineLimit(0).foregroundStyle(.black)
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
            .sectionText(font: .subheadline,color: Color.black)
            Spacer()
            toggleCategoriesButton.foregroundStyle(Color.black)
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
            searchTextField
            if !iVar.collapseCategories{
                categoriesGridView
            }
        }
        .padding(.bottom)
    }
    
    var body:some View{
        ZStack{
            categories
        }
        .background{
            RoundedRectangle(cornerRadius: 10.0).fill(Color.lightText.opacity(0.6))
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
        .foregroundStyle(Color.systemBlue)
        .hTrailing()
    }
    
    var textField:some View{
        TextField("",text:$iVar.searchText.max(MAX_TEXTFIELD_LEN))
            .preferedSearchField()
            .placeholder(when: focusField != .FIND_STORED_TUBE && iVar.searchText.isEmpty){ Text("search").foregroundStyle(.black)}
            .focused($focusField,equals: .FIND_STORED_TUBE)
            .hLeading()
            .onSubmit {
                startSearch()
            }
            .submitLabel(.search)
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
        .foregroundStyle(.black)
        .padding([.leading,.trailing])
    }
    
    func startSearch(){
        let txt = iVar.searchText.trimmingCharacters(in: .whitespaces)
        if txt.isEmpty { return }
        if let categorie = iVar.searchCategorie{
            onSearch(categorie,txt)
        }
    }
    
    func resetCurrentSearch(){
        if let categorie = iVar.searchCategorie{
            iVar.searchOption[SearchCategorie.indexOf(op: categorie)] = false
        }
        focusField = nil
        iVar.searchCategorie = nil
        iVar.searchResult = 0
        iVar.searchText = ""
        onReset()
    }
}
