import Foundation
import Supabase

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://fybfuykxbwhlhmjyscor.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5YmZ1eWt4YndobGhtanlzY29yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5ODU3MDAsImV4cCI6MjA4ODU2MTcwMH0.K6jfzovubmVsIAGUQ3RZbta0RB1HGDPjjqm4NGL5Rh4"
    )
}
