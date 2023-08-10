//
//  PieChartView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.04.2023.
//

import SwiftUI

struct PieChartView: View {
    public let values: [Double]
    public var colors: [Color]
    public var textColors: [Color]
    public let names: [String]
    
    public var backgroundColor: Color
    public var innerRadiusFraction: CGFloat
    
    private var circleSize: CGFloat {
        return innerRadiusFraction < 0.5 ? innerRadiusFraction * 2 : 1
    }
    
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(
                PieSliceData(
                    startAngle: Angle(degrees: endDeg),
                    endAngle: Angle(degrees: endDeg + degrees),
                    text: value > 0 ? String(format: "%.0f%%", value * 100 / sum) : "",
                    color: self.colors[i],
                    textColor: self.textColors[i]
                )
            )
            endDeg += degrees
        }
        return tempSlices
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                ZStack{
                    ForEach(0..<self.values.count, id: \.self) { i in
                        PieSliceView(pieSliceData: self.slices[i])
                    }
                    .frame(width: geometry.size.width * circleSize, height: geometry.size.width * circleSize)
                    
                    Circle()
                        .fill(self.backgroundColor)
                        .frame(width: geometry.size.width * innerRadiusFraction, height: geometry.size.width * innerRadiusFraction)
                }
                PieChartRows(colors: self.colors, names: self.names, values: self.values.map { String(Int($0)) }, percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
            }
            .background(self.backgroundColor)
            .foregroundColor(Color.white)
        }
    }
}

struct PieChartRows: View {
    var colors: [Color]
    var names: [String]
    var values: [String]
    var percents: [String]
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach(0..<self.values.count, id: \.self) { i in
                HStack(alignment: .top) {
                    Circle()
                        .fill(self.colors[i])
                        .frame(width: 20, height: 20)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(self.names[i])
                            .foregroundColor(Color("Gray"))
                            .font(.footnote)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading) {
                            HStack {
                                Text(self.values[i])
                                    .foregroundColor(Color.black)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(
            values: [12, 3],
            colors: [Color("Blue"), Color("LightBlue"), Color.orange],
            textColors: [.white, .black],
            names: ["Gi session", "No Gi session"],
            backgroundColor: Color.white, innerRadiusFraction: 0.3
        )
        .padding(30)
    }
}

