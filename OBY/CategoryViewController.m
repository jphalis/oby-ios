//
//  CategoryViewController.m
//

#import <QuartzCore/QuartzCore.h>

#import "CategoryTableViewCell.h"
#import "CategoryViewController.h"
#import "defs.h"
#import "SCLAlertView.h"


@interface CategoryViewController ()<UITableViewDataSource,UITableViewDelegate>{
    __weak IBOutlet UITableView *tblVw;
}
- (IBAction)onBack:(id)sender;
@end

@implementation CategoryViewController

// Need to fix this to be dynamic based on admin entries
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GetCategories count];    //count number of rows from counting array
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSArray *colors = @[
        [UIColor colorWithRed:(83/255.0) green:(117/255.0) blue:(171/255.0) alpha:1.0], // #5375ab
        [UIColor colorWithRed:(214/255.0) green:(115/255.0) blue:(221/255.0) alpha:1.0], // #D673DD
        [UIColor colorWithRed:(252/255.0) green:(165/255.0) blue:(101/255.0) alpha:1.0], // #fca565
        [UIColor colorWithRed:(79/255.0) green:(112/255.0) blue:(166/255.0) alpha:1.0], // #4f70a6
        [UIColor colorWithRed:(248/255.0) green:(108/255.0) blue:(181/255.0) alpha:1.0], // #f86cb5
        [UIColor colorWithRed:(185/255.0) green:(243/255.0) blue:(205/255.0) alpha:1.0], // #b9f3cd
        [UIColor colorWithRed:(239/255.0) green:(248/255.0) blue:(165/255.0) alpha:1.0], // #eff8a5
        [UIColor colorWithRed:(244/255.0) green:(173/255.0) blue:(249/255.0) alpha:1.0], // #f4adf9
        [UIColor colorWithRed:(254/255.0) green:(80/255.0) blue:(46/255.0) alpha:1.0], // #fe502e
        [UIColor colorWithRed:(83/255.0) green:(117/255.0) blue:(171/255.0) alpha:1.0], // #5375ab
    ];
    NSInteger colorIndex = indexPath.row % colors.count;
    
    cell.catBackground.layer.borderColor = [colors[colorIndex] CGColor];
    cell.catBackground.layer.borderWidth = 2.0f;
    cell.catBackground.layer.cornerRadius = 12;
    cell.catTitle.text = [GetCategories objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tblVw cellForRowAtIndexPath:indexPath];
    
    if([[GetCategories objectAtIndex:indexPath.row] isEqual: @"Popular"]){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Sorry, but you cannot post in the Popular category." closeButtonTitle:@"OK" duration:0.0f];
        return;
    }
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [self.delegate chooseCategory:[GetCategories objectAtIndex:indexPath.row]selectedIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
